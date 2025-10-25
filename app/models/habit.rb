class Habit 
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Paranoia
    include Auditable

    belongs_to :account
    has_many :habit_checks, dependent: :destroy
    belongs_to :habit_category, optional: true

    belongs_to :parent_habit, class_name: 'Habit', optional: true
    has_many :children_habits, class_name: 'Habit', foreign_key: :parent_habit_id, dependent: :destroy

    field :rule_engine_enabled, type: Boolean, default: false 
    field :rule_engine_details, type: Hash

    field :name, type: String
    field :description, type: String

    field :order, type: Float, default: nil

    field :start_date, type: String
    field :end_date, type: String

    field :last_check, type: Date

    # infinite, daily, weekly, monthly, yearly
    field :recurrence_type, type: String
    field :recurrence_details, type: Hash

    # Delta configuration
    field :delta_enabled, type: Boolean, default: false
    embeds_many :habit_deltas, cascade_callbacks: true
    accepts_nested_attributes_for :habit_deltas, allow_destroy: true

    # Validations
    validates :name, presence: true
    validates :start_date, presence: true
    validates :recurrence_type, presence: true

    validate :date_validation
    validate :recurrence_type_validation
    validate :recurrence_details_validation

    private

    def recurrence_details_validation
      if recurrence_details.blank?
        errors.add(:recurrence_details, "must be present and have a rule")
      end

      if recurrence_details.present? && recurrence_details[:rule].blank?
        errors.add(:recurrence_details, "must have a rule")
      end

      rrule_exists = recurrence_details.present? && recurrence_details[:rule].present?

      if rrule_exists && !RruleInternal.validate_rrule(recurrence_details[:rule])
        errors.add(:recurrence_details, "RRULE is invalid")
      end
    end

    def recurrence_type_validation
      if recurrence_type.present? && !%w(infinite daily weekly monthly yearly).include?(recurrence_type)
        errors.add(:recurrence_type, "must be one of: infinite, daily, weekly, monthly, yearly")
      end
    end

    def date_validation
      # if model is being created
      return if !new_record?

      start_date_obj = Date.parse(start_date) if start_date.present?

      if start_date.present? && Date.parse(start_date) < Date.today
        errors.add(:start_date, "must be in the future")
      end

      if start_date.present? && end_date.present? && start_date >= end_date
        errors.add(:start_date, "must be before the end date")
      end
    end
  end