class Comment < ActiveRecord::Base
  acts_as_tree
  belongs_to :commentable, :polymorphic => true
  belongs_to :content
end
