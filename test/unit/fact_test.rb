require File.dirname(__FILE__) + '/../test_helper'

class FactTest < ActiveRecord::TestCase
  test "should find latest" do
    @latest = Fact.latest
    assert_equal 2, @latest.length
    assert @latest[0].created_at > @latest[1].created_at
  end
end
