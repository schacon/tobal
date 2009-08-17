require File.dirname(__FILE__) + '/../test_helper'

class HandleTest < Test::Unit::TestCase
  fixtures :handles

  def setup
    @handle = Handle.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Handle,  @handle
  end
end
