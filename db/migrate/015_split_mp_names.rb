class SplitMpNames < ActiveRecord::Migration
  def self.up
    
    add_column :politicians, :last_name, :string
    add_column :politicians, :first_name, :string
    add_column :politicians, :second_name, :string
    
    Politician.find(:all).each do |mp|
      fn = mp.full_name.split
      mp.first_name = fn[0]
      if fn.size == 2 then
        mp.last_name = fn[1]
      end
      if fn.size == 3 then
        mp.second_name = fn[1]
        mp.last_name = fn[2]
      end
      mp.save
    end    
  end

  def self.down
    remove_column :politicians, :last_name
    remove_column :politicians, :first_name
    remove_column :politicians, :second_name  
  end
end