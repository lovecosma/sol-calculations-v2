# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NumberTypes", type: :request do
  describe "GET /numerology/number_types" do
    it "returns a success response" do
      get number_types_path
      expect(response).to be_successful
    end

    it "renders the index template" do
      get number_types_path
      expect(response).to render_template(:index)
    end

    it "orders number types by position" do
      first  = create(:number_type).tap { |nt| nt.update_column(:position, 1) }
      second = create(:number_type, :expression).tap { |nt| nt.update_column(:position, 2) }

      get number_types_path

      first_pos  = response.body.index(NumberType::HUMAN_NAMES[first.name])
      second_pos = response.body.index(NumberType::HUMAN_NAMES[second.name])
      expect(first_pos).to be < second_pos
    end
  end

  describe "GET /numerology/number_types/:number_type" do
    let!(:num_type) { create(:number_type) }

    it "returns a success response" do
      get number_type_path(number_type: num_type.name)
      expect(response).to be_successful
    end

    it "renders the show template" do
      get number_type_path(number_type: num_type.name)
      expect(response).to render_template(:show)
    end

    it "shows the number type heading" do
      get number_type_path(number_type: num_type.name)
      expect(response.body).to include(NumberType::HUMAN_NAMES[num_type.name])
    end

    it "shows numerology numbers ordered by value" do
      create(:numerology_number, number_type: num_type, number: create(:number, value: 9))
      create(:numerology_number, number_type: num_type, number: create(:number, value: 1))

      get number_type_path(number_type: num_type.name)

      expect(response.body.index(">1<")).to be < response.body.index(">9<")
    end

    it "only shows numerology numbers for the given number type" do
      other_type = create(:number_type, :expression)
      belonging  = create(:numerology_number, :with_description, number_type: num_type,   number: create(:number, value: 2), thumbnail_description: "belongs to this type")
      other      = create(:numerology_number, :with_description, number_type: other_type, number: create(:number, value: 3), thumbnail_description: "belongs to other type")

      get number_type_path(number_type: num_type.name)

      expect(response.body).to include(belonging.thumbnail_description)
      expect(response.body).not_to include(other.thumbnail_description)
    end
  end
end
