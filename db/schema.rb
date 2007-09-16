# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 1) do

  create_table "bill_versions", :force => true do |t|
    t.column "title",           :string,   :limit => 250, :default => "",        :null => false
    t.column "summary",         :text,                    :default => "",        :null => false
    t.column "billtext",        :text,                    :default => "",        :null => false
    t.column "status",          :string,   :limit => 20,  :default => "pending", :null => false
    t.column "status_comment",  :text,                    :default => "",        :null => false
    t.column "bill_version_id", :integer
    t.column "change_level",    :float,                   :default => 0.0,       :null => false
    t.column "size",            :integer,                 :default => 0,         :null => false
    t.column "version",         :integer,                 :default => 0,         :null => false
    t.column "bill_id",         :integer,  :limit => 10
    t.column "author_id",       :integer
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
  end

  add_index "bill_versions", ["bill_id"], :name => "bill_id"

  create_table "bill_versions_users", :force => true do |t|
    t.column "bill_version_id", :integer,               :default => 0, :null => false
    t.column "user_id",         :integer, :limit => 10, :default => 0, :null => false
  end

  create_table "bills", :force => true do |t|
    t.column "version_id",    :integer
    t.column "sponsor_count", :integer
  end

  create_table "bills_tags", :id => false, :force => true do |t|
    t.column "bill_id", :integer, :default => 0, :null => false
    t.column "tag_id",  :integer, :default => 0, :null => false
  end

  create_table "bills_users", :force => true do |t|
    t.column "bill_id",     :integer,               :default => 0,     :null => false
    t.column "user_id",     :integer, :limit => 10, :default => 0,     :null => false
    t.column "author",      :boolean,               :default => false, :null => false
    t.column "contributor", :boolean,               :default => false, :null => false
    t.column "sponsor",     :boolean,               :default => false, :null => false
    t.column "subscriber",  :boolean,               :default => false, :null => false
  end

  create_table "comments", :force => true do |t|
    t.column "commentable_id",   :integer
    t.column "commentable_type", :string
    t.column "comment",          :text
    t.column "user_id",          :integer
    t.column "name",             :string
    t.column "homepage",         :string
    t.column "created_at",       :datetime
    t.column "parent_id",        :integer
    t.column "email",            :string
  end

  create_table "contents", :force => true do |t|
    t.column "title",          :string
    t.column "content_type",   :string
    t.column "content",        :text
    t.column "short_content",  :text
    t.column "user_id",        :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
    t.column "published_flag", :boolean
    t.column "subtitle",       :string
    t.column "author",         :string
    t.column "url",            :text
    t.column "pdf",            :string
    t.column "screenshot",     :string
    t.column "quote_text",     :text
    t.column "render_type",    :string
  end

  create_table "handles", :force => true do |t|
    t.column "handle",  :integer
    t.column "bill_id", :integer
  end

  add_index "handles", ["handle"], :name => "handle"
  add_index "handles", ["bill_id"], :name => "bill_id"

  create_table "invites", :force => true do |t|
    t.column "email",   :string
    t.column "bill_id", :integer
    t.column "user_id", :integer
  end

  create_table "taggings", :force => true do |t|
    t.column "tag_id",        :integer
    t.column "taggable_id",   :integer
    t.column "taggable_type", :string
  end

  create_table "tags", :force => true do |t|
    t.column "name", :string
  end

  create_table "users", :force => true do |t|
    t.column "salted_password", :string,   :limit => 40,  :default => "", :null => false
    t.column "email",           :string,   :limit => 60,  :default => "", :null => false
    t.column "name",            :string,   :limit => 200
    t.column "salt",            :string,   :limit => 40,  :default => "", :null => false
    t.column "verified",        :integer,                 :default => 0
    t.column "role",            :string,   :limit => 40
    t.column "security_token",  :string,   :limit => 40
    t.column "token_expiry",    :datetime
    t.column "deleted",         :integer,                 :default => 0
    t.column "delete_after",    :datetime
    t.column "street1",         :string
    t.column "street2",         :string
    t.column "city",            :string
    t.column "state",           :string,   :limit => 2
    t.column "zip_code",        :string,   :limit => 10
  end

end
