class CreateDebateReferences < ActiveRecord::Migration
  def self.up
    create_table :debate_references do |t|
      t.integer :politician_id, :name_reference_id, :sitting_id
    end
  end

  def self.down
    drop_table :debate_references
  end
end
