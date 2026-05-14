Rails.application.routes.draw do
  root "pages#home"

  devise_for :users

  resources :owners
  resources :pets
  resources :vets
  resources :appointments do
    resources :treatments, only: [:new, :create, :edit, :update, :destroy]
  end
end