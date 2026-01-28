require 'rails_helper'

# This is an alternative version of the charts_controller_spec.rb using FactoryBot
# You can use this instead of the manual version once FactoryBot is fully set up
RSpec.describe ChartsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:valid_attributes) do
    attributes_for(:chart)
  end

  let(:invalid_attributes) do
    attributes_for(:chart, :invalid)
  end

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @charts with current user\'s charts ordered by created_at desc' do
      chart1 = create(:chart, user: user)
      sleep(0.01) # Ensure different timestamps
      chart2 = create(:chart, user: user)

      get :index

      expect(assigns(:charts)).to eq([chart2, chart1])
    end

    it 'does not include other users\' charts' do
      user_chart = create(:chart, user: user)
      other_chart = create(:chart, user: other_user)

      get :index

      expect(assigns(:charts)).to include(user_chart)
      expect(assigns(:charts)).not_to include(other_chart)
    end
  end

  describe 'GET #show' do
    let(:chart) { create(:chart, user: user) }

    it 'returns a success response' do
      get :show, params: { id: chart.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested chart to @chart' do
      get :show, params: { id: chart.to_param }
      expect(assigns(:chart)).to eq(chart)
    end

    context 'when chart does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :show, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new chart to @chart' do
      get :new
      expect(assigns(:chart)).to be_a_new(Chart)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Chart' do
        expect {
          post :create, params: { chart: valid_attributes }
        }.to change(Chart, :count).by(1)
      end

      it 'associates the chart with the current user' do
        post :create, params: { chart: valid_attributes }
        expect(Chart.last.user).to eq(user)
      end

      it 'redirects to the created chart' do
        post :create, params: { chart: valid_attributes }
        expect(response).to redirect_to(chart_path(Chart.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Chart' do
        expect {
          post :create, params: { chart: invalid_attributes }
        }.not_to change(Chart, :count)
      end

      it 'renders the new template' do
        post :create, params: { chart: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { chart: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    let(:chart) { create(:chart, user: user) }

    it 'returns a success response' do
      get :edit, params: { id: chart.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested chart to @chart' do
      get :edit, params: { id: chart.to_param }
      expect(assigns(:chart)).to eq(chart)
    end
  end

  describe 'PATCH/PUT #update' do
    let(:chart) { create(:chart, user: user) }

    context 'with valid parameters' do
      let(:new_attributes) do
        {
          full_name: 'Jane Marie Smith',
          birthdate: Date.new(1992, 8, 25)
        }
      end

      it 'updates the requested chart' do
        patch :update, params: { id: chart.to_param, chart: new_attributes }
        chart.reload
        expect(chart.full_name).to eq('Jane Marie Smith')
        expect(chart.birthdate).to eq(Date.new(1992, 8, 25))
      end

      it 'redirects to the chart' do
        patch :update, params: { id: chart.to_param, chart: new_attributes }
        expect(response).to redirect_to(chart_path(chart))
      end
    end

    context 'with invalid parameters' do
      it 'does not update the chart' do
        original_name = chart.full_name
        patch :update, params: { id: chart.to_param, chart: invalid_attributes }
        chart.reload
        expect(chart.full_name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch :update, params: { id: chart.to_param, chart: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable entity status' do
        patch :update, params: { id: chart.to_param, chart: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:chart) { create(:chart, :with_chart_numbers, user: user) }

    it 'destroys the requested chart' do
      expect {
        delete :destroy, params: { id: chart.to_param }
      }.to change(Chart, :count).by(-1)
    end

    it 'redirects to the charts list' do
      delete :destroy, params: { id: chart.to_param }
      expect(response).to redirect_to(charts_path)
    end

    it 'sets a success notice' do
      delete :destroy, params: { id: chart.to_param }
      expect(flash[:notice]).to eq('Chart deleted successfully.')
    end

    it 'destroys associated chart_numbers' do
      expect {
        delete :destroy, params: { id: chart.to_param }
      }.to change(ChartNumber, :count).by(-2) # Created with trait :with_chart_numbers
    end
  end

  describe 'Authentication' do
    before do
      sign_out user
    end

    it 'redirects to sign in for index when not authenticated' do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to sign in for create when not authenticated' do
      post :create, params: { chart: valid_attributes }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
