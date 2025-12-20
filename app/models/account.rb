class Account
  include Mongoid::Document
  include ActiveModel::SecurePassword
  include Mongoid::Timestamps

  has_many :habits, class_name: 'Habits::Habit'
  has_many :habit_checks
  has_many :moods
  has_one :subscription

  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :phone, type: String, default: nil
  field :world_address, type: String, default: nil
  field :connected_providers, type: Array, default: ['web']

  validates :world_address, uniqueness: true, allow_nil: true

  has_secure_password validations: false
end
