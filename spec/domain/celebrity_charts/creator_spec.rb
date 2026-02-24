# frozen_string_literal: true

require "rails_helper"

RSpec.describe CelebrityCharts::Creator do
  let(:celebrity_data) do
    {
      "original_name" => "Marie Curie",
      "birthday"      => "1867-11-07",
      "profile_path"  => "/abc123.jpg"
    }
  end

  describe ".run" do
    it "creates a CelebrityChart" do
      expect { described_class.run(celebrity_data: celebrity_data) }
        .to change(CelebrityChart, :count).by(1)
    end

    it "sets the full_name from original_name" do
      described_class.run(celebrity_data: celebrity_data)
      expect(CelebrityChart.last.full_name).to eq("Marie Curie")
    end

    it "sets the birthdate" do
      described_class.run(celebrity_data: celebrity_data)
      expect(CelebrityChart.last.birthdate).to eq(Date.new(1867, 11, 7))
    end

    it "sets the profile_path" do
      described_class.run(celebrity_data: celebrity_data)
      expect(CelebrityChart.last.profile_path).to eq("/abc123.jpg")
    end

    it "strips whitespace from original_name" do
      described_class.run(celebrity_data: celebrity_data.merge("original_name" => "  Marie Curie  "))
      expect(CelebrityChart.last.full_name).to eq("Marie Curie")
    end

    context "when a chart with the same full_name already exists" do
      before { CelebrityChart.create!(full_name: "Marie Curie", birthdate: Date.new(1867, 11, 7)) }

      it "does not create a duplicate" do
        expect { described_class.run(celebrity_data: celebrity_data) }
          .not_to change(CelebrityChart, :count)
      end

      it "returns the existing chart" do
        existing = CelebrityChart.find_by(full_name: "Marie Curie")
        result = described_class.run(celebrity_data: celebrity_data)
        expect(result).to eq(existing)
      end
    end

    context "when original_name is blank" do
      it "returns nil and does not create a chart" do
        expect { described_class.run(celebrity_data: celebrity_data.merge("original_name" => "")) }
          .not_to change(CelebrityChart, :count)
      end

      it "returns nil when original_name is whitespace only" do
        result = described_class.run(celebrity_data: celebrity_data.merge("original_name" => "   "))
        expect(result).to be_nil
      end
    end

    context "when birthday is blank" do
      it "returns nil and does not create a chart" do
        expect { described_class.run(celebrity_data: celebrity_data.merge("birthday" => nil)) }
          .not_to change(CelebrityChart, :count)
      end

      it "returns nil when birthday is empty string" do
        result = described_class.run(celebrity_data: celebrity_data.merge("birthday" => ""))
        expect(result).to be_nil
      end
    end

    context "when profile_path is nil" do
      it "creates the chart without a profile_path" do
        described_class.run(celebrity_data: celebrity_data.merge("profile_path" => nil))
        expect(CelebrityChart.last.profile_path).to be_nil
      end
    end
  end
end
