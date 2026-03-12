require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def trigger_record_not_found
      raise ActiveRecord::RecordNotFound
    end
  end

  let(:user) { create(:user) }

  before do
    sign_in user
    routes.draw do
      get 'trigger_record_not_found' => 'anonymous#trigger_record_not_found'
    end
  end

  describe 'rescue_from ActiveRecord::RecordNotFound' do
    before { get :trigger_record_not_found }

    it 'returns 404 status' do
      expect(response).to have_http_status(:not_found)
    end

    it 'renders the not_found template' do
      expect(response).to render_template('errors/not_found')
    end
  end
end
