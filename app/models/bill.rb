class Bill < ActiveRecord::Base 
  acts_as_taggable
  has_many :comments, :as => :commentable 
  
  has_many :bill_versions         
  has_many :pending_bill_versions, :class_name => 'BillVersion', :conditions => "status = 'pending'"

  has_many :handles
                 
  belongs_to :current_version, :class_name => 'BillVersion', :foreign_key => 'version_id'
  
  has_many :bills_users
  has_many :users, :through => :bills_users
   
  def next_version()
    arr = Bill.find_by_sql(["select max(version) as max from bill_versions where bill_id = ?", self.id])
    bill = arr[0]
    return (bill.max.to_i + 1)
  end
  
  def authors
    User.find(:all, :include => [:bills_users => [:bill]], 
                    :conditions => ['bills_users.author = 1 and bill_id = ?', self.id] )
  end
       
  def contributors
    User.find(:all, :include => [:bills_users => [:bill]], 
                    :conditions => ['(bills_users.author = 1 or bills_users.contributor = 1) and bill_id = ?', self.id] )
  end  
  
  def sponsors
    User.find(:all, :include => [:bills_users => [:bill]], 
                    :conditions => ['bills_users.sponsor = 1 and bill_id = ?', self.id] )
  end         
     
  def add_sponsor(user)
    bu = BillsUser.find_or_create_by_bill_id_and_user_id(self.id, user.id)    
    if bu.author != 1
      bu.sponsor = 1                                                      
      bu.save  
      self.set_sponsor_count
    end
  end
  
  def set_sponsor_count
      self.sponsor_count = User.count(:include => [:bills_users => [:bill]], 
                    :conditions => ['bills_users.sponsor = 1 and bill_id = ?', self.id] )  
      self.save
  end
  
  def add_author(user)
    bu = BillsUser.find_or_create_by_bill_id_and_user_id(self.id, user.id)
    bu.author = 1
    bu.save
  end
  
  def add_contributor(user)
    bu = BillsUser.find_or_create_by_bill_id_and_user_id(self.id, user.id)
    bu.contributor = 1
    bu.save
  end  
   
  def user_is_author?(user)
    BillsUser.count(:conditions => ['user_id = ? and bill_id = ? and author = 1', user.id, self.id]) > 0
  end
      
  def related
    if (tags = self.tagged_list) && tags.size > 0
      return Content.find_by_sql([
                  "SELECT DISTINCT contents.* FROM bills, tags, taggings " +
                  "WHERE bills.id = taggings.taggable_id " +
                  "AND taggings.taggable_type = ? " +
                  "AND taggings.tag_id = tags.id AND tags.name IN (?)" + 
                  "AND bill.id != ? ",
                  acts_as_taggable_options[:taggable_type], tags, self.id
                ])
    end
  end
  
  def self.tag_list
    return Tag.find_by_sql([
          "SELECT tags.*, count(*) as count FROM bills, tags, taggings " +
          "WHERE bills.id = taggings.taggable_id " +
          "AND taggings.taggable_type = ? " +
          "AND taggings.tag_id = tags.id " + 
          "GROUP BY tags.name", 
          acts_as_taggable_options[:taggable_type]
        ])
  end
      
end
