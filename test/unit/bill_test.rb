require File.dirname(__FILE__) + '/../test_helper'

class BillTest < Test::Unit::TestCase
  fixtures :bills

  def setup
    @bill = Bill.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Bill,  @bill
  end
end
