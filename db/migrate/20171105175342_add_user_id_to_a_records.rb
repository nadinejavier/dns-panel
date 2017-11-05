class AddUserIdToARecords < ActiveRecord::Migration[5.1]
  def change
    add_column :a_records, :user_id, :integer
  end
end
