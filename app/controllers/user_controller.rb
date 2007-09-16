class UserController < ApplicationController
  model   :user
  layout 'simple'
  before_filter :login_required, :except => ['login', 'logout', 'signup']

  def login
    return if generate_blank
    @user = User.new(@params['user'])
    if @session['user'] = User.authenticate(@params['user']['email'], @params['user']['password'])
      flash['notice'] = l(:user_login_succeeded)
      redirect_back_or_default :action => 'welcome'
    else
      @email = @params['user']['email']
      flash.now['message'] = l(:user_login_failed)
    end
  end

  def signup
    return if generate_blank
    @params['user'].delete('form')
    @user = User.new(@params['user'])
    begin
      User.transaction(@user) do
        @user.new_password = true
        if @user.save
          key = @user.generate_security_token
          url = url_for(:action => 'welcome')
          url += "?id=#{@user.id}&key=#{key}"
          UserNotify.deliver_signup(@user, @params['user']['password'], url)
          flash['notice'] = "Your login information has been sent to your email address"
          redirect_to :action => 'login'
        end
      end
    rescue
      flash.now['message'] = l(:user_confirmation_email_error)
    end
  end  
  
  def logout
    @session['user'] = nil
    redirect_to :action => 'login'
  end

  def change_password
    return if generate_filled_in
    @params['user'].delete('form')
    begin
      User.transaction(@user) do
        @user.change_password(@params['user']['password'], @params['user']['password_confirmation'])
        if @user.save
          UserNotify.deliver_change_password(@user, @params['user']['password'])
          flash.now['notice'] = l(:user_updated_password, "#{@user.email}")
          redirect_to :action => 'login'
        end
      end
    rescue Exception => e
      flash.now['message'] = e
    end
  end

  def forgot_password
    # Always redirect if logged in
    if user?
      flash['message'] = l(:user_forgot_password_logged_in)
      redirect_to :action => 'change_password'
      return
    end

    # Render on :get and render
    return if generate_blank

    # Handle the :post
    if @params['user']['email'].empty?
      flash.now['message'] = l(:user_enter_valid_email_address)
    elsif (user = User.find_by_email(@params['user']['email'])).nil?
      flash.now['message'] = l(:user_email_address_not_found, "#{@params['user']['email']}")
    else
      begin
        User.transaction(user) do
          key = user.generate_security_token
          url = url_for(:action => 'change_password')
          url += "?id=#{user.id}&key=#{key}"
          UserNotify.deliver_forgot_password(user, url)
          flash['notice'] = l(:user_forgotten_password_emailed, "#{@params['user']['email']}")
          unless user?
            redirect_to :action => 'login'
            return
          end
          redirect_back_or_default :action => 'welcome'
        end
      rescue
        flash.now['message'] = l(:user_forgotten_password_email_error, "#{@params['user']['email']}")
      end
    end
  end

  def edit
    return if generate_filled_in
    if @params['user']['form']
      form = @params['user'].delete('form')
      begin
        case form
        when "edit"
          changeable_fields = ['first_name', 'first_name']
          params = @params['user'].delete_if { |k,v| not changeable_fields.include?(k) }
          @user.attributes = params
          @user.save
        when "change_password"
          change_password
        #when "delete"
        #  delete
        else
          raise "unknown edit action"
        end
      end
    end
  end
  
=begin
  def delete
    @user = @session['user']
    begin
      if UserSystem::CONFIG[:delayed_delete]
        User.transaction(@user) do
          key = @user.set_delete_after
          url = url_for(:action => 'restore_deleted')
          url += "?id=#{@user.id}&key=#{key}"
          UserNotify.deliver_pending_delete(@user, url)
        end
      else
        destroy(@user)
      end
      logout
    rescue
      flash.now['message'] = l(:user_delete_email_error, "#{@user['email']}")
      redirect_back_or_default :action => 'welcome'
    end
  end

  def restore_deleted
    @user = @session['user']
    @user.deleted = 0
    if not @user.save
      flash.now['notice'] = l(:user_restore_deleted_error, "#{@user['login']}")
      redirect_to :action => 'login'
    else
      redirect_to :action => 'welcome'
    end
  end
=end

  def welcome 
    redirect_to :controller => 'bills', :action => 'index'
  end

  protected

  def destroy(user)
    UserNotify.deliver_delete(user)
    flash['notice'] = l(:user_delete_finished, "#{user['login']}")
    user.destroy()
  end

  def protect?(action)
    if ['login', 'signup', 'forgot_password'].include?(action)
      return false
    else
      return true
    end
  end

  # Generate a template user for certain actions on get
  def generate_blank
    case @request.method
    when :get
      @user = User.new
      render
      return true
    end
    return false
  end

  # Generate a template user for certain actions on get
  def generate_filled_in
    @user = @session['user'] 
    
    if params['user'] && params['key']
    end
    
    case @request.method
    when :get
      render
      return true
    end
    return false
  end
end
