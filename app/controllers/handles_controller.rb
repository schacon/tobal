class HandlesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @handle_pages, @handles = paginate :handle, :per_page => 10
  end

  def show
    @handle = Handle.find(params[:id])
  end

  def new
    @handle = Handle.new
  end

  def create
    @handle = Handle.new(params[:handle])
    if @handle.save
      flash[:notice] = 'Handle was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @handle = Handle.find(params[:id])
  end

  def update
    @handle = Handle.find(params[:id])
    if @handle.update_attributes(params[:handle])
      flash[:notice] = 'Handle was successfully updated.'
      redirect_to :action => 'show', :id => @handle
    else
      render :action => 'edit'
    end
  end

  def destroy
    Handle.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
