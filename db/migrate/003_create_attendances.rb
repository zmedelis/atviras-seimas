class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.integer :politician_id
      t.integer :sitting_id
      t.boolean :present
    end
  end

  def self.down
    drop_table :attendances
  end
end
