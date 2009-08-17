class AddInitialUser < ActiveRecord::Migration
  def self.up
    u = User.new({:email => 'admin@admin.com', :name => 'Administrator', :role => 'admin'})
    u.change_password('admin', 'admin')
    u.update_expiry
    u.save
  end

  def self.down
    User.find_by_email('admin@admin.com').destroy
  end
end
