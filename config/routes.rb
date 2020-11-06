Rails.application.routes.draw do
  root 'products#index'
  get 'purchases/edit', to: 'purchases#edit'
  resources :purchases, only: [:index, :new]
  resources :categories, only: [:index, :show]
  resources :products, only: [:index, :show, :new, :create, :edit, :create] do
    collection do
      get 'get_category_children', defaults: { format: 'json' }
      get 'get_category_grandchildren', defaults: { format: 'json' }
    end
  end
end

