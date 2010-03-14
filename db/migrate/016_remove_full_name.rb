class RemoveFullName < ActiveRecord::Migration
  def self.up
    remove_column :politicians, :full_name
  end

  def self.down
    add_column :politicians, :full_name, :string
  end
end
