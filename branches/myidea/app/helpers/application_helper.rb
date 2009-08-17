require 'uri'

module ApplicationHelper
  include Localization
  include Transforms
  
  def nlink_to(name, options = {}, html_options = {}, *parameters_for_method_reference)
    link_to(name, options, html_options.update(:class => "navlink"), *parameters_for_method_reference)
  end

  def differences(original, newer)
    HTMLDiff.diff(original, newer)
  end
   
  def bill_format(text)
    text.gsub("\n", "<br/>")
  end  
  
  def short_date(date)
    date.strftime("%b %e")
  end   
  
  def tiny_date(date)
    date.strftime("%b %e")
  end
  
  def status_icon(status)
    case status
    when 'accepted'
      '<img alt="accepted" title="accepted" src="/images/icons/accept.png">'
    when 'rejected'
      '<img alt="rejected" title="rejected" src="/images/icons/cross.png">'
    else
      '<img alt="pending" title="pending" src="/images/icons/tag.png">'
    end
  end  
  
  def digg_link(url, title, bodytext = nil)  
    url = URI.escape(url) rescue nil
    title = URI.escape(title) rescue nil
    bodytext = URI.escape(bodytext) rescue nil
    "<a href=\"http://digg.com/submit?phase=2&url=#{url}&title=#{title}&bodytext=#{bodytext}&topic=politics\">"
  end        
  
  def digg_icon
    '<img border="0" src="http://digg.com/img/badges/16x16-digg-thumb.gif" width="16" height="16" alt="Digg!" />'
  end
  
  def server_url_for(options = {})
    url_for options.update(:only_path => false)
  end
       
       
end
                                                                        
