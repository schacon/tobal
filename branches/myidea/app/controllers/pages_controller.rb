class PagesController < ApplicationController 
          
  def index
    unless read_fragment :action => 'index'
      @recent_bills = Bill.find(:all, :include => :current_version, :order => 'created_at DESC', :limit => 10)
      @popular_bills = Bill.find(:all, :include => :current_version, :order => 'sponsor_count DESC', :limit => 10)
    end
  end      
  
  def uncache
    expire_fragment :controller => 'pages', :action => 'index'
    expire_fragment %r{bills/show/\d*}
    render :text => 'ok'
  end
  
end