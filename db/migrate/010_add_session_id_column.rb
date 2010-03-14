class AddSessionIdColumn < ActiveRecord::Migration
  def self.up
    add_column :sittings, :session_id, :int
  end

  def self.down
    remove_column :sittings, :session_id
  end
end
