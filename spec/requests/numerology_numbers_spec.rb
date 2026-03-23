# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NumerologyNumbers", type: :request do
  let(:user)     { create(:user) }
  let(:num_type) { create(:number_type) }
  let(:num)      { create(:number, value: 1) }
  let(:nn) do
    create(:numerology_number, :with_description, number: num, number_type: num_type).tap do |n|
      n.update!(matches: [ 3, 5 ], mismatches: [ 2, 4 ])
    end
  end

  before { sign_in user }

  describe "GET /numerology/:number_type/:value" do
    context "when the numerology number exists" do
      before { nn }

      def do_request
        get numerology_number_path(number_type: num_type.name, value: num.value)
      end

      it "returns a success response" do
        do_request
        expect(response).to be_successful
      end

      it "renders the show template" do
        do_request
        expect(response).to render_template(:show)
      end

      it "shows the numerology number" do
        do_request
        expect(response.body).to include(nn.primary_title)
      end
    end

    context "matches and mismatches" do
      let(:match_num3)    { create(:number, value: 3) }
      let(:match_num5)    { create(:number, value: 5) }
      let(:mismatch_num2) { create(:number, value: 2) }
      let(:mismatch_num4) { create(:number, value: 4) }

      let(:match3)    { create(:numerology_number, :with_description, number: match_num3,    number_type: num_type) }
      let(:match5)    { create(:numerology_number, :with_description, number: match_num5,    number_type: num_type) }
      let(:mismatch2) { create(:numerology_number, :with_description, number: mismatch_num2, number_type: num_type) }
      let(:mismatch4) { create(:numerology_number, :with_description, number: mismatch_num4, number_type: num_type) }

      before do
        nn
        match3; match5; mismatch2; mismatch4
        get numerology_number_path(number_type: num_type.name, value: num.value)
      end

      let(:harmonious_section)  { response.body.split("Challenging Matches").first }
      let(:challenging_section) { response.body.split("Challenging Matches").last }

      it "renders match values in the harmonious matches section" do
        expect(harmonious_section).to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 3")
        expect(harmonious_section).to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 5")
      end

      it "does not render mismatch values in the harmonious matches section" do
        expect(harmonious_section).not_to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 2")
        expect(harmonious_section).not_to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 4")
      end

      it "renders mismatch values in the challenging matches section" do
        expect(challenging_section).to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 2")
        expect(challenging_section).to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 4")
      end

      it "does not render match values in the challenging matches section" do
        expect(challenging_section).not_to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 3")
        expect(challenging_section).not_to include("#{NumberType::HUMAN_NAMES[num_type.name]}: 5")
      end

      context "when a matching number exists under a different number_type" do
        let(:other_type)  { create(:number_type, :expression) }
        let(:other_match) { create(:numerology_number, :with_description, number: match_num3, number_type: other_type) }

        before do
          other_match
          get numerology_number_path(number_type: num_type.name, value: num.value)
        end

        it "does not show the other type match in the harmonious matches section" do
          expect(harmonious_section).not_to include("#{NumberType::HUMAN_NAMES[other_type.name]}: 3")
        end
      end
    end

    context "when the numerology number is not found" do
      it "returns 404" do
        get numerology_number_path(number_type: "life_path", value: "99")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      before do
        sign_out user
        nn
      end

      it "returns a success response" do
        get numerology_number_path(number_type: num_type.name, value: num.value)
        expect(response).to be_successful
      end
    end
  end
end
