# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChartNumber, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let(:user) { create(:user) }
  let(:chart) { create(:chart, user: user) }
  let(:number_type) { create(:number_type, :expression) }
  let(:number) { create(:number, value: 5) }
  let(:numerology_number) { create(:numerology_number, number_type: number_type, number: number) }
  let(:chart_number) { create(:chart_number, chart: chart, numerology_number: numerology_number) }

  describe "associations" do
    it { expect(chart_number.chart).to eq(chart) }
    it { expect(chart_number.numerology_number).to eq(numerology_number) }
  end

  describe "touch: true" do
    it "touches the chart's updated_at when created" do
      original_updated_at = chart.updated_at

      travel 1.second do
        create(:chart_number, chart: chart, numerology_number: numerology_number)
        expect(chart.reload.updated_at).to be > original_updated_at
      end
    end

    it "touches the chart's updated_at when destroyed" do
      chart_number = create(:chart_number, chart: chart, numerology_number: numerology_number)
      original_updated_at = chart.reload.updated_at

      travel 1.second do
        chart_number.destroy
        expect(chart.reload.updated_at).to be > original_updated_at
      end
    end
  end

  describe "delegates" do
    it "delegates #name to number_type via numerology_number" do
      expect(chart_number.name).to eq(number_type.name)
    end

    it "delegates #value to number via numerology_number" do
      expect(chart_number.value).to eq(number.value)
    end

    it "delegates #number_type to numerology_number" do
      expect(chart_number.number_type).to eq(number_type)
    end

    it "delegates #number to numerology_number" do
      expect(chart_number.number).to eq(number)
    end

    it "delegates #description to numerology_number" do
      expect(chart_number.description).to eq(numerology_number.description)
    end

    it "delegates #primary_title to numerology_number" do
      expect(chart_number.primary_title).to eq(numerology_number.primary_title)
    end
  end

  describe ".ordered" do
    it "orders by number_type position" do
      life_path_type = create(:number_type).tap { |nt| nt.update!(position: 1) }
      expression_type = create(:number_type, :expression).tap { |nt| nt.update!(position: 2) }

      expression_cn = create(:chart_number, chart: chart, numerology_number: create(:numerology_number, number_type: expression_type, number: create(:number, value: 3)))
      life_path_cn  = create(:chart_number, chart: chart, numerology_number: create(:numerology_number, number_type: life_path_type,  number: create(:number, value: 7)))

      ordered = chart.chart_numbers.ordered.to_a
      expect(ordered.index(life_path_cn)).to be < ordered.index(expression_cn)
    end
  end
end
