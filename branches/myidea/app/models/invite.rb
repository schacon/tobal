class Invite < ActiveRecord::Base
  belongs_to :bill
  belongs_to :user
  
  def self.log(email, bill, user)
    i = Invite.new
    i.email = email
    i.bill = bill
    i.user = user
    i.save
  end
  
end
