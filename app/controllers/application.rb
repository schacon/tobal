# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.     
require 'localization'
require 'user_system'

class ApplicationController < ActionController::Base
  include Localization
  include UserSystem
  helper :user
  model :user

  before_filter :require_www

  def require_www
    subdomain = request.subdomains.first
    return true if subdomain == 'www'
    #logger.info request.env.collect {|k,v| "#{k}=#{v}"}.join("\n")

    # we need this for caching to work
    #redirect_to 'http://www.thereoughtabealaw.org' + request.env['REQUEST_URI']
  end
end
