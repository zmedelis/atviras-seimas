class CreatePoliticalGroupVotes < ActiveRecord::Migration
  def self.up
    create_table :political_group_votes do |t|
      t.integer :political_group_id
      t.integer :question_id
      t.string  :time, :limit => 8
      t.integer :action_yes
      t.integer :action_no
      t.integer :action_absent
      t.integer :action_abstain
      t.integer :action_novote
      
    end
  end

  def self.down
    drop_table :political_group_votes
  end
end
