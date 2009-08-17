require File.dirname(__FILE__) + '/../test_helper'

class BillVersionTest < Test::Unit::TestCase
  fixtures :bill_versions

  def setup
    @bill_version = BillVersion.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of BillVersion,  @bill_version
  end
end
