Rails.application.routes.draw do
    get 'ping', to: 'ping#index'
    post 'ping', to: 'ping#index'

    scope :api do
      scope :v1 do
        scope module: 'private' do
          get 'auth/test', to: 'auth#test'

          get 'me', to: 'me#me'

          get 'habits/:id', to: 'habits#show'
          get 'habits', to: 'habits#index'
          post 'habits', to: 'habits#create'
          put 'habits/:id', to: 'habits#update'
          delete 'habits/:id', to: 'habits#destroy'

          get 'habits-check', to: 'habits_check#all'
          get 'habits-check/:habit_id', to: 'habits_check#index'
          get 'habits-check/:habit_id/:check_id', to: 'habits_check#show'
          post 'habits-check/:habit_id', to: 'habits_check#create'
          put 'habits-check/:habit_id/:check_id', to: 'habits_check#update_check'

          resources :habits_category, only: [:index, :create, :update, :destroy]
          resources :mood

          post 'checkout/create', to: 'checkout#create'

          get 'plans', to: 'plans#index'
      end

      scope module: 'public' do

        post 'auth/sign-in', to: 'auth#sign_in'
        post 'auth/sign-up', to: 'auth#sign_up'
      end

      scope module: 'internal' do
        post 'stripe/webhook', to: 'stripe_webhook#webhook'
      end
    end
  end
end
