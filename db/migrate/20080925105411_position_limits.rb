class PositionLimits < ActiveRecord::Migration
  def self.up
    change_column :positions, :title, :string, { :limit=> 80 }
    change_column :positions, :department, :string, { :limit=> 80 }
  end

  def self.down
  end
end
