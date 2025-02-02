class HabitCategory 
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account

  has_many :habits, dependent: :nullify

  field :name, type: String
  field :order, type: Float, default: 0

  validates :name, presence: true, uniqueness: { scope: :account_id }
end
