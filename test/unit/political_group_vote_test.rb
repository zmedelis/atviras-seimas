require 'test_helper'

class PoliticalGroupVoteTest < ActiveSupport::TestCase
  fixtures :political_group_votes, :questions, :politicians, :votes, :political_groups
  
  def test_truth
    assert true
  end
end
