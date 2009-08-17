class Clock
  def at( *params )
    Time.at params
  end

  def now
    Time.now
  end

  def time=
    raise "Cannot set time on real Clock class"
  end
end