class AddVoteSid < ActiveRecord::Migration
  def self.up
     add_column :votes, :sid, :integer
  end

  def self.down
    remove_column :votes, :sid
  end
end
