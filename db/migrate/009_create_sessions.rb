class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string :name
      t.date :from
      t.date :to, {:null => true}
    end
  end

  def self.down
    drop_table :sessions
  end
end
