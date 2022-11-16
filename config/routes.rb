Rails.application.routes.draw do
  devise_for :users

  root to: 'generate_experiment_plates#index'
  resources :generate_experiment_plates
  post "generate_experiment_plates/new"
  post "generate_experiment_plates/generate_experiment_plate"
end
