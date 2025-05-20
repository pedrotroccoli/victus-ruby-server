module Public
  class AuthController < ApplicationController
    def sign_in
      accounts_params = params.require(:account).permit(:email, :password)

      account = Account.find_by(email: accounts_params[:email])

      if account && account.authenticate(accounts_params[:password])
        if !account.connected_providers.include?('web')
          account.connected_providers << 'web'
          account.save
        end

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
          },
          allow_promotion_codes: true
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

    def start_siwe_auth
      #nonce = Siwe::Util.generate_nonce
      nonce = '451999bb'

      cookies.signed[:siwe_nonce] = {
        value: nonce,
        path: '/',
        httponly: true,
        secure: Rails.env.production?
      }

      puts "\n\n #{cookies.signed[:siwe_nonce]} \n\n"

      render json: { nonce: nonce }, status: :ok
    end

    def siwe_verify
      siwe_params = params[:payload]
      nonce = params[:nonce]

      if siwe_params.blank? || nonce.blank?
        return render json: { message: 'Invalid message -1' }, status: :unauthorized
      end

      # Initialize AWS Lambda client
      lambda_client = Aws::Lambda::Client.new(
        region: 'us-east-1',
      )

      lambda_payload = {
        payload: siwe_params,
        nonce: nonce
      }.to_json

      lambda_response = lambda_client.invoke({
        function_name: 'victus-siwe-dev-world-siwe-verify',
        invocation_type: 'RequestResponse',
        payload: lambda_payload
      })

      response_body = JSON.parse(lambda_response.payload.read)

      if lambda_response.status_code != 200
        return render json: { message: 'Something went wrong' }, status: :unauthorized
      end

      if response_body['valid'] == false
        return render json: { message: 'Invalid message' }, status: :unauthorized
      end

      account = Account.find_or_create_by(world_address: response_body['data']['address'])

      if !account.new_record?
        token = JWT.encode({ account_id: account.id }, ENV['JWT_SECRET'], 'HS256')

        if !account.connected_providers.include?('worldapp')
          account.connected_providers << 'worldapp'
          account.save
        end

        if account.subscription.nil?
          account.subscription = Subscription.new(
          status: 'active',
          sub_status: 'active',
          service_type: 'worldapp',
          service_details: {
            # trial_ends_at: 14.days.from_now
          }
          )

        account.subscription.save

        end

        return render json: { message: 'Signed in successfully', token: token, account: account }, status: :ok
      end

      account.connected_providers << 'worldapp'

      account.subscription = Subscription.new(
        status: 'active',
        sub_status: 'active',
        service_type: 'worldapp',
        service_details: {
          # trial_ends_at: 14.days.from_now
        }
      )
      if account.save
        token = JWT.encode({ account_id: account.id }, ENV['JWT_SECRET'], 'HS256')

        render json: { message: 'Signed in successfully', token: token }, status: :ok
      else
        render json: { message: 'Something went wrong' }, status: :unauthorized
      end
      
    rescue Exception => e
      render json: { message: 'Invalid message 1', error: e }, status: :unauthorized
    end
  end
end