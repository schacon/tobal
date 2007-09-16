class Content < ActiveRecord::Base   
  acts_as_taggable
  has_many :comments, :as => :commentable  
  belongs_to :user
  
  def content_rendered
    if render_type == 'html'
      return self.content
    end
    return textilize (self.content)
  end
  
  def icon
    return case content_type
      when 'archive' then 'icons/page_white_compressed.png'
      when 'mockup' then 'icons/pictures.png'
      else                'icons/page_white_text.png'
      end
  end
  
  def self.render_types
    ['textile', 'html']
  end
  
  def self.recent_articles(limit = 10)
    self.find(:all, :conditions => "content_type = 'article' and published_flag = 1", 
              :order => 'created_at DESC', :limit => limit)
  end
  
  def related
    if (tags = self.tagged_list) && tags.size > 0
      return Content.find_by_sql([
                  "SELECT DISTINCT contents.* FROM contents, tags, taggings " +
                  "WHERE contents.id = taggings.taggable_id " +
                  "AND taggings.taggable_type = ? " +
                  "AND taggings.tag_id = tags.id AND tags.name IN (?)" + 
                  "AND contents.id != ? ",
                  acts_as_taggable_options[:taggable_type], tags, self.id
                ])
    end
  end
  
  def self.tag_list
    return Tag.find_by_sql([
          "SELECT tags.*, count(*) as count FROM contents, tags, taggings " +
          "WHERE contents.id = taggings.taggable_id " +
          "AND taggings.taggable_type = ? " +
          "AND taggings.tag_id = tags.id " + 
          "GROUP BY tags.name", 
          acts_as_taggable_options[:taggable_type]
        ])
  end
  
  private 
  
    def textilize(text)
     if text.blank?
       ""
     else
       textilized = RedCloth.new(text, [ :hard_breaks ])
       textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
       textilized.to_html
     end
    end
  
end
