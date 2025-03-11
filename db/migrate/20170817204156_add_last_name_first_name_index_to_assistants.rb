class AddLastNameFirstNameIndexToAssistants < ActiveRecord::Migration[5.0]
  def change
    add_index :users, [:last_name, :first_name]
  end
end
