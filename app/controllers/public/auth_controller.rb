module Public
  class AuthController < ApplicationController
    def sign_in
      accounts_params = params.require(:account).permit(:email, :password)

      account = Account.find_by(email: accounts_params[:email])

      if account && account.authenticate(accounts_params[:password])
        token = JWT.encode({ account_id: account.id }, ENV['JWT_SECRET'], 'HS256')

        render json: { message: 'Signed in successfully', token: token }, status: :ok
      else
        render json: { message: 'Invalid email or password' }, status: :unauthorized
      end
    end

    def sign_up
      accounts_params = params.require(:account).permit(:email, :password, :name, :phone, :password_confirmation)

      if accounts_params[:password] != accounts_params[:password_confirmation]
        return render json: { message: 'Password and password confirmation do not match' }, status: :unauthorized
      end

      already_exists = Account.find_by(email: accounts_params[:email])

      return render json: { message: 'Account already exists' }, status: :unauthorized if already_exists

      account = Account.new(accounts_params)

      lookup_key = params[:lookup_key]

      checkout_url = nil

      if lookup_key.present?
        customer = Stripe::Customer.create(email: accounts_params[:email])

        account.subscription = Subscription.create(
          service_details: {
            status: 'pending',
            sub_status: 'pending_payment_information',
            customer_id: customer.id
          }
        )

        price = Stripe::Price.list(
          lookup_keys: [lookup_key],
          expand: ['data.product']
        )

        checkout_session = Stripe::Checkout::Session.create(
          customer: customer.id,
          mode: 'subscription',
          line_items: [{ price: price.data.first.id, quantity: 1 }],
          success_url: "#{ENV['APP_URL']}/checkout/?checkout_success=true",
          cancel_url: "#{ENV['APP_URL']}/checkout/?checkout_cancel=true",
          metadata: {
            account_id: account.id,
            lookup_key: lookup_key
          },
          subscription_data: {
            trial_period_days: 14
          }
        )

        checkout_url = checkout_session.url
      else 
        account.subscription = Subscription.new(
          status: 'pending',
          sub_status: 'pending_payment_information',
          service_details: {
            trial_ends_at: 14.days.from_now
          }
        )
      end

      if account.save
        account.subscription.save
        token = JWT.encode({ account_id: account.id }, ENV['JWT_SECRET'], 'HS256')

        EmailJob.perform_later(account.id)

        render json: { token: token, message: 'Signed up successfully', checkout_url: checkout_url }, status: :ok
      else
        render json: { message: 'Something went wrong' }, status: :unauthorized
      end
    end
  end
end