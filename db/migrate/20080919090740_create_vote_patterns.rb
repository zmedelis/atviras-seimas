class CreateVotePatterns < ActiveRecord::Migration
  def self.up
    create_table :vote_patterns do |t|
      t.integer :politician_id, :similar_voter_id
      t.float :score
    end
  end

  def self.down
    drop_table :vote_patterns
  end
end
