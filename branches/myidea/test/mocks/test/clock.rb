
class Clock
  @@time = Time.now
  cattr_writer :time

  def self.now
    @@time
  end

  def self.at( epoch )
    Time.at( epoch )
  end

  def self.advance_by_days( days )
    @@time += (days * 60 *60 * 24)
  end

end
