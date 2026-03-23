# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Charts", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }

  let(:valid_attrs)   { attributes_for(:chart) }
  let(:invalid_attrs) { attributes_for(:chart, :invalid) }

  before { sign_in user }

  describe "GET /charts" do
    it "returns a success response" do
      get charts_path
      expect(response).to be_successful
    end

    it "renders the index template" do
      get charts_path
      expect(response).to render_template(:index)
    end

    it "shows the current user's charts" do
      chart1 = create(:chart, user: user, full_name: "Alice Smith")
      chart2 = create(:chart, user: user, full_name: "Bob Jones")

      get charts_path

      expect(response.body).to include("Alice Smith", "Bob Jones")
    end

    it "orders charts by created_at descending" do
      older = travel_to(2.days.ago) { create(:chart, user: user, full_name: "Older Chart") }
      newer = travel_to(1.day.ago)  { create(:chart, user: user, full_name: "Newer Chart") }

      get charts_path

      expect(response.body.index("Newer Chart")).to be < response.body.index("Older Chart")
    end

    it "does not show other users' charts" do
      other_chart = create(:chart, user: other_user, full_name: "Other User Chart")

      get charts_path

      expect(response.body).not_to include("Other User Chart")
    end

    it "accepts a page param" do
      get charts_path, params: { page: 2 }
      expect(response).to be_successful
    end
  end

  describe "GET /charts/:id" do
    let(:chart) { create(:chart, user: user, full_name: "Jane Doe") }

    it "returns a success response" do
      get chart_path(chart)
      expect(response).to be_successful
    end

    it "renders the show template" do
      get chart_path(chart)
      expect(response).to render_template(:show)
    end

    it "shows the chart" do
      get chart_path(chart)
      expect(response.body).to include(chart.full_name)
    end

    context "when the chart does not exist" do
      it "returns 404" do
        get chart_path(id: 99999)
        expect(response).to have_http_status(:not_found)
      end

      it "renders the not_found template" do
        get chart_path(id: 99999)
        expect(response).to render_template("errors/not_found")
      end
    end
  end

  describe "GET /charts/new" do
    it "returns a success response" do
      get new_chart_path
      expect(response).to be_successful
    end

    it "renders the new template" do
      get new_chart_path
      expect(response).to render_template(:new)
    end
  end

  describe "POST /charts" do
    context "with valid parameters" do
      it "creates a new UserChart" do
        expect {
          post charts_path, params: { chart: valid_attrs }
        }.to change(UserChart, :count).by(1)
      end

      it "associates the chart with the current user" do
        post charts_path, params: { chart: valid_attrs }
        expect(UserChart.last.user).to eq(user)
      end

      it "redirects to the created chart" do
        post charts_path, params: { chart: valid_attrs }
        expect(response).to redirect_to(chart_path(UserChart.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new UserChart" do
        expect {
          post charts_path, params: { chart: invalid_attrs }
        }.not_to change(UserChart, :count)
      end

      it "renders the new template" do
        post charts_path, params: { chart: invalid_attrs }
        expect(response).to render_template(:new)
      end

      it "returns unprocessable entity status" do
        post charts_path, params: { chart: invalid_attrs }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /charts/:id/edit" do
    let(:chart) { create(:chart, user: user) }

    it "returns a success response" do
      get edit_chart_path(chart)
      expect(response).to be_successful
    end

    it "renders the edit template" do
      get edit_chart_path(chart)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH /charts/:id" do
    let(:chart) { create(:chart, user: user) }

    context "with valid parameters" do
      let(:new_attrs) { { full_name: "Jane Marie Smith", birthdate: Date.new(1992, 8, 25) } }

      it "updates the chart full_name" do
        patch chart_path(chart), params: { chart: new_attrs }
        expect(chart.reload.full_name).to eq("Jane Marie Smith")
      end

      it "updates the chart birthdate" do
        patch chart_path(chart), params: { chart: new_attrs }
        expect(chart.reload.birthdate).to eq(Date.new(1992, 8, 25))
      end

      it "redirects to the chart" do
        patch chart_path(chart), params: { chart: new_attrs }
        expect(response).to redirect_to(chart_path(chart))
      end
    end

    context "with invalid parameters" do
      it "does not update the chart" do
        original_name = chart.full_name
        patch chart_path(chart), params: { chart: invalid_attrs }
        expect(chart.reload.full_name).to eq(original_name)
      end

      it "renders the edit template" do
        patch chart_path(chart), params: { chart: invalid_attrs }
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        patch chart_path(chart), params: { chart: invalid_attrs }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /charts/:id" do
    let!(:chart) { create(:chart, :with_chart_numbers, user: user) }

    it "destroys the chart" do
      expect {
        delete chart_path(chart)
      }.to change(UserChart, :count).by(-1)
    end

    it "redirects to the charts list" do
      delete chart_path(chart)
      expect(response).to redirect_to(charts_path)
    end

    it "sets a success notice" do
      delete chart_path(chart)
      expect(flash[:notice]).to eq("Chart deleted successfully.")
    end

    it "destroys associated chart_numbers" do
      count = chart.chart_numbers.count
      expect {
        delete chart_path(chart)
      }.to change(ChartNumber, :count).by(-count)
    end
  end

  describe "Authentication" do
    before { sign_out user }

    it "redirects to sign in for index" do
      get charts_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in for create" do
      post charts_path, params: { chart: valid_attrs }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
