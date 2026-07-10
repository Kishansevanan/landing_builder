Rails.application.routes.draw do
  devise_for :users

  resources :pages, only: %i[index show new create update] do
    member { post :publish }
  end

  get "/p/:slug", to: "public_pages#show", as: :public_page

  root to: "pages#index"
end
