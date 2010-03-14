class ChangePositionsTypeName < ActiveRecord::Migration
  def self.up
    rename_column('positions', 'type', 'job_type')
  end

  def self.down
  end
end
