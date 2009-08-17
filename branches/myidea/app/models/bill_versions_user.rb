class BillVersionsUser < ActiveRecord::Base  
  belongs_to :user
  belongs_to :bill_version
end
