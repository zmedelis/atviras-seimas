class AddQuestionSid < ActiveRecord::Migration
  def self.up
     add_column :questions, :sid, :integer
  end

  def self.down
    remove_column :questions, :sid
  end
end
