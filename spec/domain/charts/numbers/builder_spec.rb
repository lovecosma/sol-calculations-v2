# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charts::Numbers::Builder do
  let(:user) { create(:user) }
  let(:chart) { create(:chart, user: user) }
  subject(:run) { described_class.run(chart: chart) }

  describe '#run' do
    context 'when calculators return values with matching NumerologyNumbers' do
      let!(:life_path_nn) do
        create(:numerology_number, :life_path, number: create(:number, value: 3))
      end
      let!(:expression_nn) do
        create(:numerology_number, :expression, number: create(:number, value: 5))
      end

      before do
        allow(Numbers::Calculators::LifePath).to receive(:run).with(chart: chart).and_return(3)
        allow(Numbers::Calculators::Expression).to receive(:run).with(chart: chart).and_return(5)
        allow(Numbers::Calculators::SoulUrge).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Personality).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Birthday).to receive(:run).with(chart: chart).and_return(nil)
      end

      it 'creates ChartNumbers for each matching NumerologyNumber' do
        expect { run }.to change { chart.chart_numbers.count }.by(2)
      end
    end

    context 'when a ChartNumber already exists for a NumerologyNumber' do
      let!(:life_path_nn) do
        create(:numerology_number, :life_path, number: create(:number, value: 3))
      end

      before do
        create(:chart_number, chart: chart, numerology_number: life_path_nn)

        allow(Numbers::Calculators::LifePath).to receive(:run).with(chart: chart).and_return(3)
        allow(Numbers::Calculators::Expression).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::SoulUrge).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Personality).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Birthday).to receive(:run).with(chart: chart).and_return(nil)
      end

      it 'does not create duplicate ChartNumbers' do
        expect { run }.not_to change { chart.chart_numbers.count }
      end
    end

    context 'when all calculators return blank values' do
      before do
        allow(Numbers::Calculators::LifePath).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Expression).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::SoulUrge).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Personality).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Birthday).to receive(:run).with(chart: chart).and_return(nil)
      end

      it 'does not create any ChartNumbers' do
        expect { run }.not_to change { ChartNumber.count }
      end
    end

    context 'when calculators return values but no matching NumerologyNumbers exist' do
      before do
        allow(Numbers::Calculators::LifePath).to receive(:run).with(chart: chart).and_return(7)
        allow(Numbers::Calculators::Expression).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::SoulUrge).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Personality).to receive(:run).with(chart: chart).and_return(nil)
        allow(Numbers::Calculators::Birthday).to receive(:run).with(chart: chart).and_return(nil)
      end

      it 'does not create any ChartNumbers' do
        expect { run }.not_to change { ChartNumber.count }
      end
    end
  end
end
