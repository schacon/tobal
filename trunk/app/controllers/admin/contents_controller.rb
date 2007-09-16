class Admin::ContentsController < Admin::AdminController
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         
  public         
    def index
      list
      render :action => 'list'
    end
  
    def list
      @content_pages, @contents = paginate :contents, :per_page => 10, :order => "created_at desc"
    end

    def show
      @article = Content.find(params[:id])
    end

    def new
      @content = Content.new
    end

    def create
      if @content = Content.create(params[:content])
        @content.user = session['user']
        @content.tag_with(params[:tags][:tag_string])
        @content.save
        flash[:notice] = 'Content was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end

    def edit
      @content = Content.find(params[:id])
    end

    def update
      @content = Content.find(params[:id])
      if @content.update_attributes(params[:content])
        @content.tag_with(params[:tags][:tag_string])
        flash[:notice] = 'Content was successfully updated.'
        redirect_to :action => 'show', :id => @content
      else
        render :action => 'edit'
      end
    end

    def destroy
      Content.find(params[:id]).destroy
      redirect_to :action => 'list'
    end
  
end