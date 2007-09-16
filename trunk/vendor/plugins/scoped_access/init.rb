ActionController::Base.instance_eval do
  def scoped_access (*args)
    options = (Hash === args.last && !(args.last.keys & [:only, :except]).empty?) ? args.pop : {}
    send(:around_filter, ScopedAccess::Filter.new(*args), options)
  end
end

