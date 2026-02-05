# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Numbers::Calculators::LifePath do
  let(:user) { create(:user) }
  let(:calculator) { described_class.new(chart: chart) }

  describe '#run' do
    context 'with regular birthdate' do
      let(:chart) { create(:chart, us er: user, birthdate: Date.new(1990, 5, 15)) }

      it 'calculates life path number' do
        # 1990-05-15 → 5+1+5+1+9+9+0 = 30 → 3+0 = 3
        expect(calculator.run).to eq(3)
      end
    end
    
    context 'with master number 11' do
      let(:chart) { create(:chart, user: user, birthdate: Date.new(1990, 1, 18)) }

      it 'preserves master number 11' do
        # 1990-01-18 → 1+9+9+0+0+1+1+8 = 29 → 2+9 = 11
        expect(calculator.run).to eq(11)
      end
    end

    context 'with master number 22' do
      let(:chart) { create(:chart, user: user, birthdate: Date.new(1982, 11, 11)) }

      it 'preserves master number 22' do
        chart = create(:chart, user: user, birthdate: Date.new(1980, 11, 11))
        calculator = described_class.new(chart: chart)
        expect(calculator.run).to eq(22)
      end
    end

    context 'with master number 33' do
      let(:chart) { create(:chart, user: user, birthdate: Date.new(1984, 11, 9)) }

      it 'preserves master number 33' do
        # 1984-11-09 → 1+9+8+4+1+1+0+9 = 33
        expect(calculator.run).to eq(33)
      end
    end
  end
end
