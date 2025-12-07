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

    field :start_date, type: DateTime
    field :end_date, type: DateTime

    field :finished_at, type: DateTime, default: nil
    field :paused_at, type: DateTime, default: nil

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
      # Only validate on create, or if recurrence_details is explicitly being set
      # Skip validation on update if recurrence_details is not being changed
      return if !new_record? && recurrence_details.blank?
      
      if recurrence_details.blank?
        errors.add(:recurrence_details, "must be present and have a rule")
        return
      end

      if recurrence_details.present? && recurrence_details[:rule].blank?
        errors.add(:recurrence_details, "must have a rule")
        return
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

      if start_date.present?
        start_date_obj = start_date.is_a?(String) ? Date.parse(start_date) : start_date.to_date
        
        if start_date_obj < Date.today
          errors.add(:start_date, "must be in the future")
        end
      end

      if start_date.present? && end_date.present?
        start_date_obj = start_date.is_a?(String) ? Date.parse(start_date) : start_date.to_date
        end_date_obj = end_date.is_a?(String) ? Date.parse(end_date) : end_date.to_date
        
        if start_date_obj >= end_date_obj
          errors.add(:start_date, "must be before the end date")
        end
      end
    end
  end