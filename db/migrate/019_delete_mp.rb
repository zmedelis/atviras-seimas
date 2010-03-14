class DeleteMp < ActiveRecord::Migration
  def self.up
    drop_table :mps
  end

  def self.down
    
  end
end
