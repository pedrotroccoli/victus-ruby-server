class HabitCheck
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :habit, class_name: 'Habits::Habit' 
  belongs_to :account

  field :checked, type: Boolean, default: false
  field :finished_at, type: DateTime

  # Delta
  embeds_many :habit_check_deltas
  accepts_nested_attributes_for :habit_check_deltas, allow_destroy: true

  # Validations
  validates :checked, presence: true
  validate :validate_time

  private

  def validate_time
    habit_rule = habit.recurrence_details[:rule]

    unless habit_rule.present?
      errors.add(:habit_rule, "Habit has no recurrence rule")
    end

    rrule = RruleInternal.new(habit_rule)

    unless rrule.is_in_range?(Time.current)
      errors.add(:out_of_date_range, "Habit check is out of date range")
    end
    
    if (checked) 
      self.finished_at = Time.now
    else
      self.finished_at = nil
    end
  end
end