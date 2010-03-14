require File.dirname(__FILE__) + '/../test_helper'

class PoliticianTest < Test::Unit::TestCase
  fixtures :questions, :politicians, :votes, :political_groups

  def test_active_votes
    assert true
  end
end
