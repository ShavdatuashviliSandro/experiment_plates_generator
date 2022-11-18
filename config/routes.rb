Rails.application.routes.draw do
  devise_for :users

  root to: 'generate_experiment_plates#index'
  resources :generate_experiment_plates

  # match '*unmatched', to: 'application#route_not_found', via: :all
end
