# add is_a_number to String to check if it is a positive integer
class String
  def is_a_number?
    begin
      !!(self =~ /\A[0-9]+\z/)
    rescue
      return false
    end
  end

  def is_mixed?
    begin
      # match digit then non-digit or non-digit then digit -> mixed
      if (self =~ /\A\d.*\D\z/) or (self =~ /\A\d.*\d\z/)
        return true
      else
        return false
      end
    rescue
      return true
    end
  end
end

