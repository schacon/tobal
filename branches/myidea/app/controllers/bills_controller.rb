class BillsController < ApplicationController     
  before_filter :login_required, :only => ['new', 'edit_bill', 'sponsor', 'create', 'edit', 'update']
       
  auto_complete_for :tag, :name
  
  def index 
    list
    render :action => 'list'
  end

  def list     
    @recent_bills = Bill.find(:all, :include => :current_version, 
                                      :order => 'created_at DESC', :limit => 10)
    @popular_bills = Bill.find(:all, :include => :current_version, 
                                      :order => 'sponsor_count DESC', :limit => 10)
    
    if @tag = params[:tag]
      @bills_tagged = Bill.find_tagged_with(@tag)
    end
 
    if @search = params[:search]
      @bills_searched = Bill.find(:all, :include => :current_version, 
                              :conditions => ['billtext like ? or title like ?', "%#{@search}%",  "%#{@search}%"],
                              :order => 'created_at', :limit => 30)
    end    
  end

  def show  
    @bill_id = params[:id]
    unless read_fragment :action => 'show', :id => @bill_id
      @bill = Bill.find(@bill_id)
      @bill_version = @bill.current_version
      @versions_pending = @bill.pending_bill_versions.count
      @comment = Comment.new 
      @bill_count = Bill.maximum(:id)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "No bill was found with that ID number, sorry"
    redirect_to :action => 'list'
  end  
  
  def view_revision
    @bill_version = BillVersion.find(params[:id])
    @bill = @bill_version.bill
    @current = @bill.current_version
    @author = @bill_version.author
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "No bill version was found with that ID number, sorry"
    redirect_to :action => 'list'
  end 
  
  def add_comment
    @bill = Bill.find(params[:id])
    @comment = Comment.new(params[:comment])
    @comment.parent_id = 0      
    if params[:human_text] == 'yes'
      @bill.comments << @comment
      if @comment.save
        expire_bill(@bill.id)
        flash[:notice] = "Comment added"
        redirect_to :action => 'show', :id => @bill
      else
        flash[:error] = "There was an error adding your comment"
        show
        render :action => 'show'
      end
    else
      flash[:error] = "Please type <strong>yes</strong> where it asks you if you're human"
      show
      render :action => 'show'
    end
  end      
  
  def send_invites
    @bill = Bill.find(params[:id])
    
    emails = EmailHelp::find_emails(params[:invites])
    emails.each do |email|
      UserMailer.deliver_invite(email, @bill, session['user']) 
      Invite.log(email, @bill, session['user'])      
    end                                     
    
    flash[:notice] = "Notifications delivered to " + emails.join(', ')
    
    redirect_to :action => 'show', :id => @bill
  end
  
  def add_tag
    @bill = Bill.find(params[:id]) 
    current_list = @bill.tag_list
    @bill.tag_with(params[:tag][:name] + ' ' + current_list)
    expire_bill(@bill.id)
    redirect_to :action => 'show', :id => @bill
  end
   
  def sponsor
    @bill = Bill.find(params[:id])             
    @bill.add_sponsor(session['user']) 
    flash[:notice] = "You are now a sponsor for this bill"     
    expire_fragment :controller => 'pages', :action => 'index' 
    expire_bill(@bill.id)
    redirect_to :action => 'show', :id => @bill
  end
  
  def print
    @bill = Bill.find(params[:id]) 
    @bill_version = @bill.current_version
    render :action => 'print', :layout => 'print'
  end
          
  def show_versions
    @bill = Bill.find(params[:id])
    @bill_versions = @bill.bill_versions.find(:all, :order => 'created_at DESC')    
  end
  
  def new
    @bill = Bill.new
    @bill_version = BillVersion.new
  end
  
  def edit_bill
    @bill = Bill.find(params[:id])
    @bill_version = @bill.current_version 
  end

  def create
    @bill = Bill.new(params[:bill])
    @bill_version = BillVersion.new(params[:bill_version]) 
    @bill_version.version = 1
    @bill_version.status = 'accepted'
    @bill_version.author_id = session['user'].id
    
    if @bill_version.save
      expire_fragment :controller => 'pages', :action => 'index'
      expire_bill(@bill.id)
      
      @bill_version.users << session['user']
      @bill.current_version = @bill_version
    
      if @bill.save  
        @bill.add_author(session['user'])
        @bill_version.bill = @bill
        @bill_version.save

        flash[:notice] = 'Bill was successfully created.'
        redirect_to :action => 'show', :id => @bill
      else
        render :action => 'new'
      end
      
    end
  end

  def edit
    @bill = Bill.find(params[:id])
  end

  def update
    @bill = Bill.find(params[:id])
    @old_version = @bill.current_version
    
    @bill_version = BillVersion.new(params[:bill_version])                               
    @bill_version.version = @bill.next_version();
    @bill_version.bill = @bill
    @bill_version.bill_version_id = @old_version   
    @bill_version.author_id = session['user'].id
    @bill_version.save
    
    @bill_version.users << session['user']
    
    if @bill_version.save
      expire_bill(@bill.id)
       
      flash[:notice] = 'Your suggested change has been sent to the author for approval.  <br/> You can review it on the <a href="/bills/show_versions/' + @bill.id.to_s + '">Bill Versions Page</a>.'
      redirect_to :action => 'show', :id => @bill
    else
      render :action => 'edit'
    end    
  end    
  
  private
  def expire_bill(bill_id)
    expire_fragment :action => 'show', :id => bill_id
  end
  
end
