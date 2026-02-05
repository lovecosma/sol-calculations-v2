# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Numbers::Calculators::Base do
  let(:user) { create(:user) }
  let(:chart) { create(:chart, user: user) }

  describe 'initialization' do
    it 'can be instantiated with a chart' do
      calculator = described_class.new(chart: chart)
      expect(calculator).to be_a(described_class)
    end
  end

  describe '#run' do
    it 'raises NotImplementedError' do
      calculator = described_class.new(chart: chart)
      expect { calculator.run }.to raise_error(NotImplementedError)
    end
  end
end
