module AccountHelper   
  def link_tab(text, partial_name, id)
    link_to_remote text, :update => 'version-viewer', :url => {:action => 'get_view', :id => id, :page => partial_name}
  end
end
