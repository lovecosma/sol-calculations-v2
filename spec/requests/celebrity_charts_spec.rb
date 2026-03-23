# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CelebrityCharts", type: :request do
  describe "GET /celebrity_charts" do
    it "returns a success response" do
      get celebrity_charts_path
      expect(response).to be_successful
    end

    it "renders the index template" do
      get celebrity_charts_path
      expect(response).to render_template(:index)
    end

    it "is publicly accessible" do
      get celebrity_charts_path
      expect(response).to be_successful
    end

    context "with celebrity charts" do
      let!(:chart1) { create(:celebrity_chart, full_name: "Ada Lovelace") }
      let!(:chart2) { create(:celebrity_chart, full_name: "Alan Turing") }

      it "shows chart1" do
        get celebrity_charts_path
        expect(response.body).to include("Ada Lovelace")
      end

      it "shows chart2" do
        get celebrity_charts_path
        expect(response.body).to include("Alan Turing")
      end

      it "does not show UserChart records" do
        user = create(:user)
        create(:chart, user: user, full_name: "Regular User Chart")

        get celebrity_charts_path

        expect(response.body).not_to include("Regular User Chart")
      end

      it "orders charts by popularity descending" do
        Celebrity.create!(celebrity_chart: chart1, external_id: 1, original_name: chart1.full_name, popularity: 10)
        Celebrity.create!(celebrity_chart: chart2, external_id: 2, original_name: chart2.full_name, popularity: 90)

        get celebrity_charts_path

        expect(response.body.index("Alan Turing")).to be < response.body.index("Ada Lovelace")
      end
    end

    context "with no celebrity charts" do
      it "shows empty state" do
        get celebrity_charts_path
        expect(response.body).to include("No celebrity charts yet.")
      end
    end

    context "filtering by name" do
      let!(:match)    { create(:celebrity_chart, full_name: "Marie Curie") }
      let!(:no_match) { create(:celebrity_chart, full_name: "Albert Einstein") }

      it "includes charts whose name matches q" do
        get celebrity_charts_path, params: { q: "marie" }
        expect(response.body).to include("Marie Curie")
      end

      it "excludes charts whose name does not match q" do
        get celebrity_charts_path, params: { q: "marie" }
        expect(response.body).not_to include("Albert Einstein")
      end

      it "matches case-insensitively" do
        get celebrity_charts_path, params: { q: "MARIE" }
        expect(response.body).to include("Marie Curie")
      end

      it "returns matching chart when q is blank" do
        get celebrity_charts_path, params: { q: "" }
        expect(response.body).to include("Marie Curie")
      end

      it "returns non-matching chart when q is blank" do
        get celebrity_charts_path, params: { q: "" }
        expect(response.body).to include("Albert Einstein")
      end
    end

    context "filtering by number type and value" do
      let!(:matching_chart)     { create(:celebrity_chart, full_name: "Marie Curie") }
      let!(:non_matching_chart) { create(:celebrity_chart, full_name: "Albert Einstein") }
      let(:num_type)            { create(:number_type) }
      let(:num)                 { create(:number, value: 7) }
      let(:nn)                  { create(:numerology_number, number: num, number_type: num_type) }

      before { create(:chart_number, chart: matching_chart, numerology_number: nn) }

      it "includes charts with the matching number type and value" do
        get celebrity_charts_path, params: { number_type: num_type.name, number_value: "7" }
        expect(response.body).to include("Marie Curie")
      end

      it "excludes charts without the matching number type and value" do
        get celebrity_charts_path, params: { number_type: num_type.name, number_value: "7" }
        expect(response.body).not_to include("Albert Einstein")
      end

      it "includes matching chart when number_type is missing" do
        get celebrity_charts_path, params: { number_value: "7" }
        expect(response.body).to include("Marie Curie")
      end

      it "includes non-matching chart when number_type is missing" do
        get celebrity_charts_path, params: { number_value: "7" }
        expect(response.body).to include("Albert Einstein")
      end

      it "includes matching chart when number_value is missing" do
        get celebrity_charts_path, params: { number_type: num_type.name }
        expect(response.body).to include("Marie Curie")
      end

      it "includes non-matching chart when number_value is missing" do
        get celebrity_charts_path, params: { number_type: num_type.name }
        expect(response.body).to include("Albert Einstein")
      end
    end

    context "number value select" do
      it "renders number values in the select when no number_type param is present" do
        num = create(:number, value: 7)
        get celebrity_charts_path
        expect(response.body).to include("value=\"#{num.value}\"")
      end

      it "renders only values for the given number_type" do
        num_type = create(:number_type)
        num_5    = create(:number, value: 5)
        create(:numerology_number, number: num_5, number_type: num_type)

        get celebrity_charts_path, params: { number_type: num_type.name }

        expect(response.body).to include("value=\"5\"")
      end

      it "excludes values from other number types" do
        num_type   = create(:number_type)
        other_type = create(:number_type, :expression)
        num_5      = create(:number, value: 5)
        num_9      = create(:number, value: 9)
        create(:numerology_number, number: num_5, number_type: num_type)
        create(:numerology_number, number: num_9, number_type: other_type)

        get celebrity_charts_path, params: { number_type: num_type.name }

        expect(response.body).not_to include("value=\"9\"")
      end
    end
  end

  describe "GET /celebrity_charts/number_values" do
    it "returns a success response" do
      get number_values_celebrity_charts_path, headers: { "Turbo-Frame" => "number_value_select" }
      expect(response).to be_successful
    end

    it "is publicly accessible" do
      get number_values_celebrity_charts_path, headers: { "Turbo-Frame" => "number_value_select" }
      expect(response).to be_successful
    end

    it "renders the number_value_select partial" do
      get number_values_celebrity_charts_path, headers: { "Turbo-Frame" => "number_value_select" }
      expect(response).to render_template(partial: "_number_value_select")
    end

    context "with a number_type param" do
      let(:num_type)   { create(:number_type) }
      let(:other_type) { create(:number_type, :expression) }

      before do
        create(:numerology_number, number_type: num_type,   number: create(:number, value: 3))
        create(:numerology_number, number_type: other_type, number: create(:number, value: 7))
      end

      it "returns only values belonging to that number type" do
        get number_values_celebrity_charts_path,
            params: { number_type: num_type.name },
            headers: { "Turbo-Frame" => "number_value_select" }

        expect(response.body).to include("value=\"3\"")
      end

      it "excludes values from other number types" do
        get number_values_celebrity_charts_path,
            params: { number_type: num_type.name },
            headers: { "Turbo-Frame" => "number_value_select" }

        expect(response.body).not_to include("value=\"7\"")
      end
    end
  end
end
