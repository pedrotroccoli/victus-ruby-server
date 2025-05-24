require 'stripe'

class StripeService
  def create_checkout(params)
    account_id = params[:account_id]
    lookup_key = params[:lookup_key]
    customer_id = params[:customer_id]

    price = Stripe::Price.list(
      lookup_keys: [lookup_key],
      expand: ['data.product']
    )

    stripe::Checkout::Session.create(
      customer: customer_id,
      mode: 'subscription',
      line_items: [{ price: price.data.first.id, quantity: 1 }],
      success_url: "#{ENV['APP_URL']}/checkout/?checkout_success=true",
      cancel_url: "#{ENV['APP_URL']}/checkout/?checkout_cancel=true",
      metadata: {
        account_id: account_id,
        lookup_key: lookup_key
      },
      subscription_data: {
        trial_period_days: 14
      },
      allow_promotion_codes: true
    )
  end

  def create_checkout_session(params)
    stripe::Checkout::Session.create({
      customer: params[:customer],
      mode: 'subscription',
      line_items: [{ price: params[:price] }]
    })
  end

  def create_customer(account_information)
    email = account_information[:email]

    stripe::Customer.create(email: email)
  end

  def create_subscription_session(params)
    stripe::BillingPortal::Session.create({
      customer: params[:customer],
      return_url: params[:return_url]
    })
  end

  private

  def stripe
    @stripe ||= begin
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      Stripe
    end
  end
end 