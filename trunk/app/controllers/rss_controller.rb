class RssController < ApplicationController
  layout nil
  
  def bill        
    bill = Bill.find(params[:id])       
    @current = bill.current_version
    @bill_versions = bill.bill_versions.find(:all, :order => 'updated_at DESC', :limit => 15)
  end  
       
  def billcomments      
    bill = Bill.find(params[:id])       
    @current = bill.current_version
    @comments = bill.comments
  end  

  def bills
    @bill_versions = BillVersion.find(:all, :conditions => ['status = ?', 'accepted'], :order => 'updated_at DESC', :limit => 20)     
  end      
  
  def comments
    @comments = Comment.find(:all, :conditions => ['commentable_type = ?', 'bill'])
  end

  def blog_articles
    @articles = Content.find(:all, :conditions => ['published_flag = 1'], :limit => 10, :order => 'created_at DESC')
  end  
       
  def blog_comments
    @comments = Comment.find(:all, :conditions => ['commentable_type = ?', 'content'])
  end  
     
end