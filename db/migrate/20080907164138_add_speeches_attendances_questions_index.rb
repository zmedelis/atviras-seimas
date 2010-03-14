class AddSpeechesAttendancesQuestionsIndex < ActiveRecord::Migration
  def self.up
    add_index :speeches, [:question_id]
    add_index :attendances, [:sitting_id]
    add_index :sittings, [:session_id]
    add_index :questions, [:sitting_id]
  end

  def self.down
    remove_index :speeches, [:question_id]
    remove_index :attendances, [:sitting_id]
    remove_index :sittings, [:session_id]
    remove_index :questions, [:sitting_id]
  end
end
