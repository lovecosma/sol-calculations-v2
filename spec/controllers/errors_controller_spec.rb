require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe 'GET #not_found' do
    before do
      routes.draw { get 'errors/not_found' => 'errors#not_found' }
      get :not_found
    end

    it 'returns 404 status' do
      expect(response).to have_http_status(:not_found)
    end

    it 'renders the not_found template' do
      expect(response).to render_template('errors/not_found')
    end

    it 'does not require authentication' do
      expect(response).not_to be_redirect
    end
  end

  describe 'GET #internal_server_error' do
    before do
      routes.draw { get 'errors/internal_server_error' => 'errors#internal_server_error' }
      get :internal_server_error
    end

    it 'returns 500 status' do
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'renders the internal_server_error template' do
      expect(response).to render_template('errors/internal_server_error')
    end

    it 'does not require authentication' do
      expect(response).not_to be_redirect
    end
  end
end
