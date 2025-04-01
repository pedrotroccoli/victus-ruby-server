class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :status, :service_type, :service_details

  has_one :account, serializer: AccountSerializer
end
