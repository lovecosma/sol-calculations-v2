require "rails_helper"

RSpec.describe CelebrityChartsController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  before do
    CelebrityChart.delete_all
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    context "with celebrity charts" do
      let!(:older_chart) { travel_to(2.days.ago) { CelebrityChart.create!(full_name: "Ada Lovelace", birthdate: Date.new(1815, 12, 10)) } }
      let!(:newer_chart) { travel_to(1.day.ago) { CelebrityChart.create!(full_name: "Alan Turing", birthdate: Date.new(1912, 6, 23)) } }

      it "assigns @charts with celebrity charts" do
        get :index
        expect(assigns(:charts)).to include(older_chart, newer_chart)
      end

      it "orders @charts by created_at descending" do
        get :index
        expect(assigns(:charts).to_a).to eq([newer_chart, older_chart])
      end

      it "does not include UserChart records" do
        user_chart = create(:chart, user: user)
        get :index
        expect(assigns(:charts)).not_to include(user_chart)
      end

      it "eager loads chart_numbers" do
        get :index
        assigns(:charts).each do |chart|
          expect(chart.association(:chart_numbers)).to be_loaded
        end
      end
    end

    context "with no celebrity charts" do
      it "assigns an empty collection" do
        get :index
        expect(assigns(:charts)).to be_empty
      end
    end

    context "pagination" do
      it "accepts a page param" do
        get :index, params: { page: 2 }
        expect(response).to be_successful
      end
    end

    context "HTTP caching" do
      let!(:chart) { CelebrityChart.create!(full_name: "Marie Curie", birthdate: Date.new(1867, 11, 7)) }

      it "sets an ETag header" do
        get :index
        expect(response.headers["ETag"]).to be_present
      end

      it "returns 304 Not Modified when ETag matches" do
        get :index
        etag = response.headers["ETag"]
        request.env["HTTP_IF_NONE_MATCH"] = etag
        get :index
        expect(response).to have_http_status(:not_modified)
      end
    end

    context "when not authenticated" do
      it "is publicly accessible" do
        get :index
        expect(response).to be_successful
      end
    end

    context "filtering by name" do
      let!(:match)    { CelebrityChart.create!(full_name: "Marie Curie", birthdate: Date.new(1867, 11, 7)) }
      let!(:no_match) { CelebrityChart.create!(full_name: "Albert Einstein", birthdate: Date.new(1879, 3, 14)) }

      it "includes charts whose name matches q" do
        get :index, params: { q: "marie" }
        expect(assigns(:charts)).to include(match)
      end

      it "excludes charts whose name does not match q" do
        get :index, params: { q: "marie" }
        expect(assigns(:charts)).not_to include(no_match)
      end

      it "matches case-insensitively" do
        get :index, params: { q: "MARIE" }
        expect(assigns(:charts)).to include(match)
      end

      it "returns all charts when q is blank" do
        get :index, params: { q: "" }
        expect(assigns(:charts)).to include(match, no_match)
      end
    end

    context "filtering by number type and value" do
      let!(:matching_chart)     { CelebrityChart.create!(full_name: "Marie Curie", birthdate: Date.new(1867, 11, 7)) }
      let!(:non_matching_chart) { CelebrityChart.create!(full_name: "Albert Einstein", birthdate: Date.new(1879, 3, 14)) }

      before do
        number_type = NumberType.find_or_create_by!(name: "life_path")
        number = Number.find_or_create_by!(value: 7)
        numerology_number = NumerologyNumber.find_or_create_by!(number: number, number_type: number_type)
        ChartNumber.create!(chart: matching_chart, numerology_number: numerology_number)
      end

      it "includes charts with the matching number type and value" do
        get :index, params: { number_type: "life_path", number_value: "7" }
        expect(assigns(:charts)).to include(matching_chart)
      end

      it "excludes charts without the matching number type and value" do
        get :index, params: { number_type: "life_path", number_value: "7" }
        expect(assigns(:charts)).not_to include(non_matching_chart)
      end

      it "does not filter when number_type is missing" do
        get :index, params: { number_value: "7" }
        expect(assigns(:charts)).to include(matching_chart, non_matching_chart)
      end

      it "does not filter when number_value is missing" do
        get :index, params: { number_type: "life_path" }
        expect(assigns(:charts)).to include(matching_chart, non_matching_chart)
      end
    end

    context "@number_values" do
      it "assigns all number values when no number_type param is present" do
        Number.find_or_create_by!(value: 3)
        Number.find_or_create_by!(value: 1)
        Number.find_or_create_by!(value: 7)

        get :index
        expect(assigns(:number_values)).to eq(Number.order(:value).pluck(:value))
      end

      it "assigns only values for the given number_type when number_type param is present" do
        number_type = NumberType.find_or_create_by!(name: "life_path")
        other_type  = NumberType.find_or_create_by!(name: "expression")
        number_5    = Number.find_or_create_by!(value: 5)
        number_9    = Number.find_or_create_by!(value: 9)
        NumerologyNumber.find_or_create_by!(number: number_5, number_type: number_type)
        NumerologyNumber.find_or_create_by!(number: number_9, number_type: other_type)

        get :index, params: { number_type: "life_path" }
        expect(assigns(:number_values)).to eq([5])
      end
    end
  end

  describe "GET #number_values" do
    it "returns a success response" do
      get :number_values
      expect(response).to be_successful
    end

    it "is publicly accessible" do
      get :number_values
      expect(response).to be_successful
    end

    it "renders the number_value_select partial" do
      get :number_values
      expect(response).to render_template(partial: "_number_value_select")
    end

    context "without a number_type param" do
      it "returns all number values ordered by value" do
        create(:number, value: 9)
        create(:number, value: 1)
        create(:number, value: 5)

        get :number_values
        expect(response.body).to include("1", "5", "9")
      end
    end

    context "with a number_type param" do
      before do
        create(:numerology_number, :life_path, number: create(:number, value: 3))
        create(:numerology_number, :expression, number: create(:number, value: 7))
      end

      it "returns only values belonging to that number type" do
        get :number_values, params: { number_type: "life_path" }
        expect(response.body).to include("3")
      end

      it "excludes values from other number types" do
        get :number_values, params: { number_type: "life_path" }
        expect(response.body).not_to include(">7<")
      end
    end
  end
end
