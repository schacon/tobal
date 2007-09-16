class BillVersion < ActiveRecord::Base   
  belongs_to :bill

  has_many :bill_versions_users
  has_many :users, :through => :bill_versions_users
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  
  # returns the change level (1-100)      
  def change_level_normal       
    max(min((self.change_level.to_f * 10), 100), 1).to_i
  end
  
  def preview(str_find)
    if pos = self.billtext.index(str_find)
      self.billtext.slice(pos - 20, pos + 20)
    else
      self.billtext[0, 40]
    end
  end
                                                                
  protected
    def before_save
      self.size = self.billtext.size
      if self.version > 1
        self.change_level = self.size / (self.bill.current_version.billtext.size + 1)
      end   
    end   
    
    def min(val1, val2)
      (val1 > val2) ? val2 : val1
    end

    def max(val1, val2)
      (val1 > val2) ? val1 : val2
    end

      
end
