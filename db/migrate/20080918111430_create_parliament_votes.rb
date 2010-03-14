class CreateParliamentVotes < ActiveRecord::Migration
  def self.up
    create_table :parliament_votes do |t|
      t.integer :question_id
      t.integer :action_yes
      t.integer :action_no
      t.integer :action_absent
      t.integer :action_abstain
      t.integer :action_novote
    end
  end

  def self.down
    drop_table :parliament_votes
  end
end
