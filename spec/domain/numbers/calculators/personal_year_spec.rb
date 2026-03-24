# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Numbers::Calculators::PersonalYear do
  let(:user) { create(:user) }
  let(:birthdate) { Date.new(1990, 5, 15) }
  let(:chart) { create(:chart, user: user, birthdate: birthdate) }
  let(:calculator) { described_class.new(chart: chart) }

  describe '#run' do
    it 'calculates the personal year number using the current year' do
      allow(Date).to receive(:today).and_return(Date.new(2026, 1, 1))
      # 5 + 1+5 + 2+0+2+6 = 21 → 2+1 = 3
      expect(calculator.run).to eq(3)
    end
  end
end
