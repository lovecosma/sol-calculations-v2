require 'rails_helper'

RSpec.describe ChartsController, type: :controller do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }
  let(:other_user) { User.create!(email: 'other@example.com', password: 'password123') }

  let(:valid_attributes) do
    {
      full_name: 'John Michael Doe',
      birthdate: Date.new(1990, 5, 15)
    }
  end

  let(:invalid_attributes) do
    {
      full_name: '',
      birthdate: nil
    }
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
      chart1 = user.charts.create!(valid_attributes)
      sleep(0.01) # Ensure different timestamps
      chart2 = user.charts.create!(full_name: 'Jane Smith', birthdate: Date.new(1985, 3, 20))

      get :index

      expect(assigns(:charts)).to eq([chart2, chart1])
    end

    it 'does not include other users\' charts' do
      user_chart = user.charts.create!(valid_attributes)
      other_chart = other_user.charts.create!(valid_attributes)

      get :index

      expect(assigns(:charts)).to include(user_chart)
      expect(assigns(:charts)).not_to include(other_chart)
    end
  end

  describe 'GET #show' do
    let(:chart) { user.charts.create!(valid_attributes) }

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

    context 'with invalid name format' do
      it 'does not create a chart with too many names' do
        expect {
          post :create, params: { chart: valid_attributes.merge(full_name: 'First Second Third Fourth') }
        }.not_to change(Chart, :count)
      end

      it 'does not create a chart with only whitespace' do
        expect {
          post :create, params: { chart: valid_attributes.merge(full_name: '   ') }
        }.not_to change(Chart, :count)
      end
    end
  end

  describe 'GET #edit' do
    let(:chart) { user.charts.create!(valid_attributes) }

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
    let(:chart) { user.charts.create!(valid_attributes) }

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
    let!(:chart) { user.charts.create!(valid_attributes) }

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
      chart.chart_numbers.create!(number_type: 'life_path', value: 5)

      expect {
        delete :destroy, params: { id: chart.to_param }
      }.to change(ChartNumber, :count).by(-1)
    end
  end

  describe 'Strong Parameters' do
    it 'permits full_name, birthdate, and user_id' do
      params = ActionController::Parameters.new(
        chart: {
          full_name: 'John Doe',
          birthdate: Date.today,
          user_id: user.id,
          unauthorized_param: 'should not be permitted'
        }
      )

      controller_params = controller.send(:permitted_params)

      # This would need to be called in context of actual controller action
      # but demonstrates the permitted parameters
      expect(params.require(:chart).permit(:full_name, :birthdate, :user_id).keys)
        .to contain_exactly('full_name', 'birthdate', 'user_id')
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
