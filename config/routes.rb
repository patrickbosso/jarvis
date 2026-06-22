Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    root "dashboards#show"

    resource :budget_rule, only: %i[edit update]
    resources :transfer_suggestions, only: %i[index update]
  end

  namespace :webhooks do
    post :qonto
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
