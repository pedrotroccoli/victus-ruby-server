RRULE_REGEX = /\AFREQ=(DAILY|WEEKLY|MONTHLY|YEARLY)(;[A-Z]+=[^;]+)*\z/

class RruleInternal
  def self.validate_rrule(rrule)
    # FREQ=DAILY;INTERVAL=1;UNTIL=20250327T000000Z

    if rrule.match(RRULE_REGEX)
      return true
    else
      return false
    end
  end

  def self.validate_rrule!(rrule)
    if !validate_rrule(rrule)
      raise RRule::InvalidRRuleError, "Invalid RRULE"
    end
  end
end
