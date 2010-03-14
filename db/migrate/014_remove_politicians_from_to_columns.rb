class RemovePoliticiansFromToColumns < ActiveRecord::Migration
  def self.up
    remove_column :politicians, :from
    remove_column :politicians, :to
  end
  
  def self.down
    add_column :politicians, :from, :date
    add_column :politicians, :to, :date
  end
end
