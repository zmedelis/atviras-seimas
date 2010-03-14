class AddRebelionColumns< ActiveRecord::Migration
  def self.up
    add_column :votes, :group_rebellion, :boolean
    add_column :votes, :parliament_rebellion, :boolean
  end
  
  def self.down
    remove_column :votes, :group_rebellion
    remove_column :votes, :parliament_rebellion
  end
end
