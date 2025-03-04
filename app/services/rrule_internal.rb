# FREQ=DAILY;INTERVAL=1;UNTIL=20250327T000000Z
RRULE_REGEX = /\AFREQ=(?<freq>DAILY|WEEKLY|MONTHLY|YEARLY)(?:;UNTIL=(?<until>\d{8}T\d{6}Z))?(?:;INTERVAL=(?<interval>\d+))?(?:;BYDAY=(?<byday>[^;]+))?(?:;[A-Z]+=?[^;]+)*\z/

class RruleInternal
  def initialize(rrule)
    self.class.validate_rrule!(rrule)
    
    @rrule = rrule
  end

  def self.validate_rrule(rrule)
    rrule ||= @rrule

    if rrule.match(RRULE_REGEX)
      return true
    else
      return false
    end
  end

  def self.validate_rrule!(rrule)
    rrule ||= @rrule

    if !validate_rrule(rrule)
      raise RRule::InvalidRRuleError, "Invalid RRULE"
    end
  end

  def is_in_range?(date)
    parse_date = DateTime.parse(date.to_s)

    if parse_date.nil?
      raise RRule::InvalidRRuleError, "Invalid date"
    end
    match_data = @rrule.match(RRULE_REGEX)

    until_date = match_data[:until]
    permitted_days = match_data[:byday]

    if until_date.present?
      until_date = DateTime.parse(until_date)

      if parse_date > until_date
        return false
      end
    end

    if permitted_days.present?
      permitted_days = permitted_days.split(",")
      
      if !permitted_days.include?(parse_date.strftime("%A").upcase[0, 2])
        return false
      end
    end

    return true
  end

  def is_in_range!(date)
    if !is_in_range?(date)
      raise RRule::InvalidRRuleError, "Date is not in range"
    end
  end
end
