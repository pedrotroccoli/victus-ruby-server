class Mood
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  
  field :value, type: String
  field :description, type: String

  validates :value, presence: true
  validates :description, presence: true

  belongs_to :account
end