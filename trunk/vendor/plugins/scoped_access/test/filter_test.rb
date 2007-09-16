require File.dirname(__FILE__) + '/test_helper'
require __DIR__ + '/fixtures/member'

class FilterGenerateConstrainTest < Test::Unit::TestCase
  def test_generate_constrain_from_hash
    scoping  = Filter.generate_constrain(Member, {:find=>{:limit=>10}})
    expected = {
      :find   => { :limit => 10 }
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_string
    scoping  = Filter.generate_constrain(Member, 'name = "Maiha"').method_scoping
    expected = {
      :find   => { :conditions => ['( members.name = "Maiha" )'] },
      :create => { },
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_array
    scoping  = Filter.generate_constrain(Member, ['name = ?', "Maiha"]).method_scoping
    expected = {
      :find   => { :conditions => ['( members.name = ? )', ["Maiha"]] },
      :create => { },
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_symbol
    assert_raise(TypeError) {
      scoping = Filter.generate_constrain(Member, :method_scoping)
    }
  end

  def test_generate_constrain_from_sql_condition
    condition = SqlCondition.new(:name => "Maiha")

    scoping = Filter.generate_constrain(Member, condition).method_scoping
    expected = {
      :find   => { :conditions => ['( members.name = ? )', ["Maiha"]] },
      :create => { 'name' => "Maiha" },
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_method_scoping
    method_scoping = MethodScoping.new(:name => "Maiha")

    scoping = Filter.generate_constrain(Member, method_scoping).method_scoping
    expected = {
      :find   => { :conditions => ['( name = ? )', ["Maiha"]] },
      :create => { 'name' => "Maiha" },
    }
    assert_equal expected, scoping
  end
end



class FilterWithMethodScopingTest < Test::Unit::TestCase
  def setup
    @controller   = Struct.new(:method_scoping).new # faked
    @class        = Member
    @filter       = Filter.new(@class)
    @nested_depth = @class.instance_eval{scoped_methods}.size
  end

  def teardown
    current_scopings = @class.instance_eval{scoped_methods}
    nested_depth     = current_scopings.size - @nested_depth
    @class.instance_eval{nested_depth.times{scoped_methods.pop}}
  end

  def test_generate_constrain_from_hash
    @controller.method_scoping = {:find=>{:limit=>10}}
    scoping  = @filter.before(@controller).last
    expected = {
      :find   => { :limit => 10 }
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_string
    @controller.method_scoping = 'name = "Maiha"'
    scoping  = @filter.before(@controller).last
    expected = {
      :find   => { :conditions => ['( members.name = "Maiha" )'] },
      :create => { },
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_array
    @controller.method_scoping = ['name = ?', "Maiha"]
    scoping  = @filter.before(@controller).last
    expected = {
      :find   => { :conditions => ['( members.name = ? )', ["Maiha"]] },
      :create => { },
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_symbol
    @controller.method_scoping = :method_scoping
    assert_raise(TypeError) {
      scoping  = @filter.before(@controller).last
    }
  end

  def test_generate_constrain_from_sql_condition
    @controller.method_scoping = SqlCondition.new(:name => "Maiha")
    scoping  = @filter.before(@controller).last
    expected = {
      :find   => { :conditions => ['( members.name = ? )', ["Maiha"]] },
      :create => { 'name' => "Maiha" },
    }
    assert_equal expected, scoping
  end

  def test_generate_constrain_from_method_scoping
    @controller.method_scoping = MethodScoping.new(:name => "Maiha")
    scoping  = @filter.before(@controller).last
    expected = {
      :find   => { :conditions => ['( name = ? )', ["Maiha"]] },
      :create => { 'name' => "Maiha" },
    }
    assert_equal expected, scoping
  end
end

