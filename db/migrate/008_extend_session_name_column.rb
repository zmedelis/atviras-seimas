class ExtendSessionNameColumn < ActiveRecord::Migration
  def self.up
    change_column :sittings, :name, :string, { :limit=> 20 }
  end

  def self.down
  end
end
