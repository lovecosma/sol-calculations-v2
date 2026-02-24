require "rails_helper"

RSpec.describe CelebrityChartsController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  before do
    CelebrityChart.delete_all
    sign_in user
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
      before { sign_out user }

      it "redirects to sign in" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
