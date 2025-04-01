class Account
  include Mongoid::Document
  include ActiveModel::SecurePassword
  include Mongoid::Timestamps

  has_many :habits
  has_many :habit_checks
  has_many :moods
  has_one :subscription

  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :phone, type: String, default: nil

  has_secure_password
end
