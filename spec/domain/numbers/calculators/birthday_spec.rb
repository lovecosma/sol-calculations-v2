# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Numbers::Calculators::Birthday do
  let(:user) { create(:user) }
  let(:chart) { create(:chart, user: user, birthdate: Date.new(1990, 5, 15)) }
  let(:calculator) { described_class.new(chart: chart) }

  describe '#run' do
    it 'returns the day of the month' do
      expect(calculator.run).to eq(15)
    end

    context 'when birthdate is nil' do
      before do
        allow(chart).to receive(:birthdate).and_return(nil)
      end

      it 'returns nil' do
        expect(calculator.run).to be_nil
      end
    end
  end
end
