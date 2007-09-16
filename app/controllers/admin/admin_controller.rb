class Admin::AdminController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required
  
  private
  def admin_login_required
    session['user'].role == 'admin'
  end
end