Rails.application.routes.draw do
  devise_for :users

  root to: 'generate_experiment_plates#index'
  resources :generate_experiment_plates
  delete '/generate_experiment_plates/:id' => 'generate_experiment_plates#destroy'
end
