class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :votes, [:politician_id]
    add_index :votes, [:question_id]
    add_index :attendances, [:politician_id]
    add_index :speeches, [:politician_id]
  end

  def self.down
    remove_index :votes, [:politician_id]
    remove_index :votes, [:question_id]
    remove_index :attendances, [:politician_id]
    remove_index :speeches, [:politician_id]
  end
end