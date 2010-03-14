class RenameQuestionType < ActiveRecord::Migration
  def self.up
    rename_column :questions, :type, :stage
  end

  def self.down
    rename_column :questions, :stage, :type
  end
end
