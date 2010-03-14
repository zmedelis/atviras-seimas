class ChangeFormulationToText < ActiveRecord::Migration
  def self.up
    change_column :questions, :formulation, :text
  end

  def self.down
    change_column :questions, :formulation, :string
  end
end
