class HabitDelta
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :type, type: String
  field :name, type: String
  field :description, type: String
  field :enabled, type: Boolean, default: true

  validates :type, presence: true
  validates :name, presence: true

  embedded_in :habit
  
  def self.types
    %w(number string time)
  end

  validate :validate_type

  private
    def validate_type
      unless self.class.types.include?(type)
        errors.add(:type, "must be one of #{self.class.types.join(', ')}")
      end
    end
end