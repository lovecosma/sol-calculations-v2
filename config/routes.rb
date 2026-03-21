Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  resources :charts
  resources :celebrity_charts do
    collection do
      get :number_values
    end
  end
  get "/numerology/number_types", to: "number_types#index", as: :number_types
  get "/numerology/number_types/:number_type", to: "number_types#show", as: :number_type
  get "/numerology/:number_type/:value", to: "numerology_numbers#show", as: :numerology_number
  # namespace "numerology" do
  #   get ':number_type/:value', to: "numerology_numbers#show", as: :numerology_number
  #   get ':number_type', to: "number_types#show", as: :number_type
  # end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  if Rails.env.test?
    get    "/test/sign_in",  to: "test/sessions#create"
    delete "/test/sign_in",  to: "test/sessions#destroy"
  end

  root "pages#index"

  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms
  get "about", to: "pages#about", as: :about

  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_server_error"

  match "*path", to: "errors#not_found", via: :all
end
