  class Habit 
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :account
    has_many :habit_checks

    field :name, type: String
    field :description, type: String

    field :start_date, type: String
    field :end_date, type: String

    field :last_check, type: Date

    # infinite, daily, weekly, monthly, yearly
    field :recurrence_type, type: String
    field :recurrence_details, type: Hash

    # Validations
    validates :name, presence: true
    validates :start_date, presence: true
    validates :recurrence_type, presence: true

    validate :date_validation
    validate :recurrence_type_validation

    private

    def recurrence_type_validation
      if recurrence_type.present? && !%w(infinite daily weekly monthly yearly).include?(recurrence_type)
        errors.add(:recurrence_type, "must be one of: infinite, daily, weekly, monthly, yearly")
      end
    end

    def date_validation
      start_date_obj = Date.parse(start_date) if start_date.present?

      if start_date.present? && Date.parse(start_date) < Date.today
        errors.add(:start_date, "must be in the future")
      end

      if start_date.present? && end_date.present? && start_date >= end_date
        errors.add(:start_date, "must be before the end date")
      end
    end
  end