class CreateHabitContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)

    required(:start_date).filled(:date)
    optional(:end_date).filled(:date)

    required(:recurrence_type).filled(:string)
    required(:recurrence_details).filled(:hash)

    required(:rule_engine_enabled).filled(:bool)
    optional(:rule_engine_details).filled(:hash)
  end

  rule(:rule_engine_details) do
    next if values[:rule_engine_enabled] == false

    unless value.present? 
      key.failure('logic is required')
      next
    end

    if value[:logic].blank?
      key.failure('logic is required')
      next
    end

    logic = value[:logic]

    if logic[:type].blank?
      key.failure('type is required')
      next
    end

    type_enum = %w(and or)

    unless type_enum.include?(logic[:type])
      key.failure("type is invalid, must be one of #{type_enum.join(', ')}")
      next
    end

    type = logic[:type]

    unless type[type].blank? || type[type].is_a?(Array)
      key.failure("#{type} condition is required and must be an array")
    end
  end
end
