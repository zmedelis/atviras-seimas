class AddLrsIdColumn < ActiveRecord::Migration
  def self.up
    add_column :politicians, :id_in_lrs, :string, :limit => 16
  end

  def self.down
    remove_column :politicians, :id_in_lrs
  end
end
