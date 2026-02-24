require "rails_helper"

RSpec.describe NumerologyNumbersController, type: :controller do
  let(:user) { create(:user) }
  let(:number_type) { create(:number_type) }
  let(:number)      { create(:number, value: 1) }
  let(:numerology_number) do
    create(:numerology_number, number: number, number_type: number_type).tap do |nn|
      nn.update!(matches: [3, 5], mismatches: [2, 4])
    end
  end

  before { sign_in user }

  describe "GET #show" do
    context "when the numerology number exists" do
      before { numerology_number }

      def do_request
        get :show, params: { number_type: number_type.name, value: number.value }
      end

      it "returns a success response" do
        do_request
        expect(response).to be_successful
      end

      it "renders the show template" do
        do_request
        expect(response).to render_template(:show)
      end

      it "assigns @numerology_number" do
        do_request
        expect(assigns(:numerology_number)).to eq(numerology_number)
      end

      it "assigns @number" do
        do_request
        expect(assigns(:number)).to eq(number)
      end

      it "assigns @number_type" do
        do_request
        expect(assigns(:number_type)).to eq(number_type)
      end

      it "eager loads number and number_type on @numerology_number" do
        do_request
        nn = assigns(:numerology_number)
        expect(nn.association(:number)).to be_loaded
        expect(nn.association(:number_type)).to be_loaded
      end

      context "HTTP caching" do
        it "sets an ETag header" do
          do_request
          expect(response.headers["ETag"]).to be_present
        end

        it "returns 304 Not Modified when ETag matches" do
          do_request
          etag = response.headers["ETag"]
          request.env["HTTP_IF_NONE_MATCH"] = etag
          do_request
          expect(response).to have_http_status(:not_modified)
        end
      end
    end

    context "matches and mismatches" do
      let(:match_number3)    { create(:number, value: 3) }
      let(:match_number5)    { create(:number, value: 5) }
      let(:mismatch_number2) { create(:number, value: 2) }
      let(:mismatch_number4) { create(:number, value: 4) }

      let(:match3)    { create(:numerology_number, number: match_number3,    number_type: number_type) }
      let(:match5)    { create(:numerology_number, number: match_number5,    number_type: number_type) }
      let(:mismatch2) { create(:numerology_number, number: mismatch_number2, number_type: number_type) }
      let(:mismatch4) { create(:numerology_number, number: mismatch_number4, number_type: number_type) }

      before do
        numerology_number
        match3; match5; mismatch2; mismatch4
        get :show, params: { number_type: number_type.name, value: number.value }
      end

      it "assigns @matches with numerology numbers whose values are in match_ids" do
        expect(assigns(:matches)).to include(match3, match5)
      end

      it "does not include mismatches in @matches" do
        expect(assigns(:matches)).not_to include(mismatch2, mismatch4)
      end

      it "assigns @mismatches with numerology numbers whose values are in mismatch_ids" do
        expect(assigns(:mismatches)).to include(mismatch2, mismatch4)
      end

      it "does not include matches in @mismatches" do
        expect(assigns(:mismatches)).not_to include(match3, match5)
      end

      context "when a matching number exists under a different number_type" do
        let(:other_type)       { create(:number_type, :expression) }
        let(:other_type_match) { create(:numerology_number, number: match_number3, number_type: other_type) }

        before do
          other_type_match
          get :show, params: { number_type: number_type.name, value: number.value }
        end

        it "does not include it in @matches" do
          expect(assigns(:matches)).not_to include(other_type_match)
        end
      end
    end

    context "when the numerology number is not found" do
      it "returns 404" do
        get :show, params: { number_type: "life_path", value: "99" }
        expect(response).to have_http_status(:not_found)
      end

      it "renders a plain text not found message" do
        get :show, params: { number_type: "life_path", value: "99" }
        expect(response.body).to include("Numerology number not found")
      end

      it "does not assign @numerology_number" do
        get :show, params: { number_type: "life_path", value: "99" }
        expect(assigns(:numerology_number)).to be_nil
      end

      it "does not assign @matches" do
        get :show, params: { number_type: "life_path", value: "99" }
        expect(assigns(:matches)).to be_nil
      end
    end

    context "when not authenticated" do
      before { sign_out user }

      it "redirects to sign in" do
        get :show, params: { number_type: "life_path", value: "1" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
