# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#show'

  post '/api/auth/callback/google', to: 'api/users#create'
  namespace :api do
    resources :memos, only: %i[index update]
    resources :reading_logs, only: %i[index create]
    resources :headings, only: %i[create update]
    resources :users, only: %i[show destroy]
    resources :user_books, only: %i[index create update destroy] do
      member do
        patch :position
      end
    end
  end
end
