class VoteActionType < ActiveRecord::Migration
  def self.up
    change_column :votes, :action, :integer
  end

  def self.down
    change_column :votes, :action, :string
  end
end
