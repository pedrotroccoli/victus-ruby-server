class HabitCheck
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :habit
  belongs_to :account

  field :checked, type: Boolean
  field :finished_at, type: DateTime
end