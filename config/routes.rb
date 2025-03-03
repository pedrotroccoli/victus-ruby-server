Rails.application.routes.draw do
  get 'ping', to: 'ping#index'
  post 'ping', to: 'ping#index'

  scope :api do
    scope :v1 do
      get 'auth/test', to: 'auth#test'

      post 'auth/sign-in', to: 'auth#sign_in'
      post 'auth/sign-up', to: 'auth#sign_up'
      get 'auth/me', to: 'auth#me'

      get 'habits/:id', to: 'habits#show'
      get 'habits', to: 'habits#index'
      post 'habits', to: 'habits#create'
      put 'habits/:id', to: 'habits#update'
      delete 'habits/:id', to: 'habits#destroy'

      get 'habits-check', to: 'habits_check#all'
      get 'habits-check/:habit_id', to: 'habits_check#index'
      post 'habits-check/:habit_id', to: 'habits_check#create'
      put 'habits-check/:habit_id/:check_id', to: 'habits_check#update'

      resources :habits_category, only: [:index, :create, :update, :destroy]
    end
  end
end
