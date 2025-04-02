WEBHOOK_SECRET = ENV['STRIPE_WEBHOOK_SECRET']

module Internal
class StripeWebhookController < ApplicationController
  before_action :verify_signature

  def webhook
    event = @event

    event_type = event.type
    data_object = event.data.object

    case event_type
    when 'customer.subscription.deleted'
      handle_subscription_deleted(data_object)
    when 'invoice.paid'
      handle_invoice_paid(data_object)
    when 'invoice.payment_failed'
      handle_payment_failed(data_object)
    when 'subscription.updated'
      handle_subscription_updated(data_object)
    else
      # Rails.logger.info("Unhandled event type: #{event_type}")
    end

    render json: {}, status: 201
  end

  private
    def handle_subscription_deleted(data_object)
      customer_id = data_object.customer

      subscription = Subscription.find_by("service_details.customer_id" => customer_id)
      account = subscription&.account

      if account.nil?
        render json: { error: 'Account not found' }, status: 404
        return
      end

      account.subscription.status = 'cancelled'
      account.subscription.cancel_date = Time.now
      account.subscription.cancel_reason = 'Customer cancelled subscription'
      account.subscription.save!
    end

    def handle_invoice_paid(data_object)
      customer_id = data_object.customer
      subscription = Subscription.find_by("service_details.customer_id" => customer_id)
      
      return if subscription.nil?
      
      subscription.status = 'active'
      subscription.sub_status = 'success'
      subscription.save!
    end

    def handle_subscription_created(data_object)
      customer_id = data_object.customer
      
      account = Subscription.find_by("service_details.customer_id" => customer_id)&.account

      if account.nil?
        render json: { error: 'Account not found' }, status: 404
        return
      end

      stripe_subscription_id = data_object.id
      trial_ends_at = data_object.trial_end

      subscription_object = {
        status: data_object.status == 'active' ? 'active' : 'freezed',
        sub_status: data_object.trial_end ? 'trial' : 'success',
        service_details: subscription.service_details.merge({
          subscription_id: stripe_subscription_id,
          trial_ends_at: trial_ends_at,
          plan_id: data_object.plan.id
        }),
      }

      if account.subscription.nil?
        account.subscription = Subscription.new(subscription_object)
      else
        account.subscription.update(subscription_object)
      end
      
      account.subscription.save!
    end

    def handle_payment_failed(data_object)
      customer_id = data_object.customer
      subscription = Subscription.find_by("service_details.customer_id" => customer_id)
      
      return if subscription.nil?

      if subscription.service_details&.failed_payments.nil?
        subscription.service_details.failed_payments = 0
      end

      if subscription.service_details&.failed_payments >= 3
        subscription.status = 'freezed'
        subscription.sub_status = 'payment_failed'
        subscription.save!
      else 
        subscription_object = {
          service_details: subscription.service_details.merge({
            failed_payments: subscription.service_details&.failed_payments + 1
          })
        }
      end

      subscription.update(subscription_object)
      subscription.save!
    end

    def verify_signature 
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil

      if (payload.nil? || sig_header.nil?)
        render json: { error: 'Missing payload or signature header' }, status: 400
        return
      end

      begin 
        @event = Stripe::Webhook.construct_event(
          payload, sig_header, WEBHOOK_SECRET
        )
      rescue JSON::ParserError => e
        render json: { error: 'Invalid payload' }, status: 400
        return
      rescue Stripe::SignatureVerificationError => e
        render json: { error: 'Invalid signature' }, status: 400
        return
      end  
    end
  end
end