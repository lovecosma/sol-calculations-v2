require "rails_helper"

RSpec.describe NumberTypesController, type: :controller do
  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "orders @number_types by position" do
      second = create(:number_type, :expression).tap { |nt| nt.update_column(:position, 2) }
      first  = create(:number_type).tap { |nt| nt.update_column(:position, 1) }

      get :index
      expect(assigns(:number_types).to_a).to eq([first, second])
    end
  end

  describe "GET #show" do
    let!(:number_type) { create(:number_type) }

    it "renders the show template" do
      get :show, params: { number_type: number_type.name }
      expect(response).to render_template(:show)
    end

    it "assigns the correct @number_type" do
      get :show, params: { number_type: number_type.name }
      expect(assigns(:number_type)).to eq(number_type)
    end

    it "orders @numerology_numbers by number value" do
      high = create(:numerology_number, number_type: number_type, number: create(:number, value: 9))
      low  = create(:numerology_number, number_type: number_type, number: create(:number, value: 1))

      get :show, params: { number_type: number_type.name }
      expect(assigns(:numerology_numbers).to_a).to eq([low, high])
    end

    it "only assigns numerology numbers for the given number type" do
      other_type = create(:number_type, :expression)
      belonging  = create(:numerology_number, number_type: number_type)
      other      = create(:numerology_number, number_type: other_type)

      get :show, params: { number_type: number_type.name }
      expect(assigns(:numerology_numbers)).to include(belonging)
      expect(assigns(:numerology_numbers)).not_to include(other)
    end
  end
end
