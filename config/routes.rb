Rails.application.routes.draw do
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "products#index"

  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]
  resources :orders, only: [:index, :show]

  get  "cart", to: "cart#show"
  post "cart/add/:id", to: "cart#add", as: "add_to_cart"
  patch "cart/update/:id", to: "cart#update", as: "update_cart"
  delete "cart/remove/:id", to: "cart#remove", as: "remove_from_cart"

  get  "checkout", to: "checkout#new"
  post "checkout", to: "checkout#create"
  get  "checkout/success", to: "checkout#success", as: :checkout_success
  get  "checkout/cancel", to: "checkout#cancel", as: :checkout_cancel

  get "up" => "rails/health#show", as: :rails_health_check
end