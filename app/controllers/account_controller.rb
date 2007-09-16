class AccountController < ApplicationController
  before_filter :login_required 
  
  def view     
    @user = session['user']                  
    @bills = Bill.find(:all, :include => [:bills_users, :bill_versions], 
              :conditions => ['bills_users.user_id = ? and bills_users.author = 1', @user.id],
              :order => 'created_at DESC')
    @versions = BillVersion.find_all_by_author_id(session['user'].id, :order => 'created_at DESC')     
    @sponsored = Bill.find(:all, :include => [:bills_users, :current_version], 
              :conditions => ['bills_users.user_id = ? and bills_users.sponsor = 1', @user.id],
              :order => 'created_at DESC')     
  end      
   
  def bill_edit
    @bill = Bill.find(params[:id])
    @bill_version = @bill.current_version 
  end          
  
  def bill_update
    @bill = Bill.find(params[:id])    
    if @bill.user_is_author?(session['user'])
      @old_version = @bill.current_version
    
      @bill_version = BillVersion.new(params[:bill_version])                               
      @bill_version.version = @bill.next_version();   
      @bill_version.status = 'accepted'
      @bill_version.bill = @bill
      @bill_version.bill_version_id = @old_version   
      @bill_version.author_id = session['user'].id
      @bill_version.save
         
      if @bill_version.save        
        expire_fragment :controller => 'pages', :action => 'index'
    	expire_fragment :controller => 'bills', :action => 'show', :id => @bill.id

        @bill.current_version = @bill_version
    
        if @bill.save  
          @bill.add_author(session['user'])   
        end
    
        flash[:notice] = 'Bill version saved'
        redirect_to :action => 'view', :id => @bill
      else
        render :action => 'bill_edit'
      end
    else                      
      flash[:error] = 'Sorry, you are not the author of that bill'
      redirect_to :action => 'view'
    end
  end
     
  def get_view
    review_revision
    partial = params[:page]
    render :partial => partial
  end
  
  def review_revision
    @version = BillVersion.find(params[:id])
    @current = @version.bill.current_version
    @author = @version.author
  end    
  
  def accept
    @version = BillVersion.find(params[:id])    
    bill = @version.bill 
    
    if bill.user_is_author?(session['user'])
      bill.version_id = params[:id]
      if bill.save 
        expire_fragment :controller => 'pages', :action => 'index'
    	expire_fragment :controller => 'bills', :action => 'show', :id => @bill.id
                                  
        @version.status_comment = params[:bill_version][:status_comment]
        @version.status = 'accepted'
        @version.save 
        
        bill.add_contributor(@version.author)               
      
        UserMailer.deliver_accept_version(@version)
      
        flash[:notice] = "New Version Accepted"
      end
    else
      flash[:notice] = "Sorry, you are not the author of that bill"
    end
    redirect_to :action => 'view'
  end
      
  def reject  
    @version = BillVersion.find(params[:id])    
    bill = @version.bill  
    
    if bill.user_is_author?(session['user'])
      @version.status_comment = params[:bill_version][:status_comment]                                
      @version.status = 'rejected'
      @version.save    
    
      UserMailer.deliver_reject_version(@version)

      flash[:notice] = "New Version Rejected"
    else
      flash[:notice] = "Sorry, you are not the author of that bill"
    end
    redirect_to :action => 'view'
  end 
end
