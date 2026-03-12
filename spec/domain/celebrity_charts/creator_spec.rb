# frozen_string_literal: true

require "rails_helper"

RSpec.describe CelebrityCharts::Creator do
  let(:celebrity) do
    Celebrity.create!(
      external_id: 1,
      original_name: "Marie Curie",
      birthdate: Date.new(1867, 11, 7),
      profile_path: "/abc123.jpg"
    )
  end

  describe ".run" do
    it "creates a CelebrityChart" do
      expect { described_class.run(celebrity: celebrity) }
        .to change(CelebrityChart, :count).by(1)
    end

    it "sets the CelebrityChart full_name from the celebrity's original_name" do
      described_class.run(celebrity: celebrity)
      expect(CelebrityChart.last.full_name).to eq("Marie Curie")
    end

    it "sets the CelebrityChart birthdate from the celebrity's birthdate" do
      described_class.run(celebrity: celebrity)
      expect(CelebrityChart.last.birthdate).to eq(Date.new(1867, 11, 7))
    end

    it "links the celebrity to the new chart" do
      described_class.run(celebrity: celebrity)
      expect(celebrity.reload.celebrity_chart).to eq(CelebrityChart.last)
    end

    context "when the celebrity already has a celebrity_chart_id" do
      before do
        existing_chart = CelebrityChart.create!(full_name: "Marie Curie", birthdate: Date.new(1867, 11, 7))
        celebrity.update!(celebrity_chart: existing_chart)
      end

      it "does not create a new CelebrityChart" do
        expect { described_class.run(celebrity: celebrity) }
          .not_to change(CelebrityChart, :count)
      end

      it "returns nil" do
        result = described_class.run(celebrity: celebrity)
        expect(result).to be_nil
      end
    end
  end
end
