module Private
  class SubscriptionController < Private::PrivateController
    def create_session
      stripe_session = StripeService.new.create_subscription_session({
        customer: @current_account.subscription.service_details['customer_id'].to_s,
        return_url: "#{ENV['APP_URL']}/account/subscription"
      })

      render json: { session_url: stripe_session.url }, status: :ok
    end
  end
end
