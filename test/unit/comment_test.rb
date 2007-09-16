require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments

  def setup
    @comment = Comment.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Comment,  @comment
  end
end
