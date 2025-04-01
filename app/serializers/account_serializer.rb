class AccountSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone

  has_one :subscription, serializer: SubscriptionSerializer
end
