class ContentController < ApplicationController      
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         
  public           
    def index
      return list
    end
    
    def list   
      if @tag = params[:tag]
        @contents = Content.find_tagged_with(@tag)
      else      
        if @search_terms = params[:search]
          search = ["published_flag = 1 and content like ?", "%#{@search_terms}%"]
          @content_pages, @contents = paginate :contents, :per_page => 20, :conditions => search, :order_by => 'created_at DESC'
        else
          @content_pages, @contents = paginate :contents, :per_page => 20, :conditions => 'published_flag = 1', :order_by => 'created_at DESC'
        end
      end
      render :action => 'list'
    end

    def view
      @content = Content.find(params[:id])
    end
    
    def add_comment
      @content = Content.find(params[:id])
      @comment = Comment.new(params[:comment])
      @comment.parent_id = 0      
      if params[:human_text] == 'yes'
        @content.comments << @comment
        if @comment.save
          flash[:notice] = "Comment added"
          redirect_to :action => 'view', :id => @content
        else
          flash[:error] = "There was an error adding your comment"
          render :action => 'view'
        end
      else
        flash[:error] = "Please type <strong>yes</strong> where it asks you if you're human"
        render :action => 'view'
      end
    end
    
end