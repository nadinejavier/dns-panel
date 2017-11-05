class CreateARecords < ActiveRecord::Migration[5.1]
  def change
    create_table :a_records do |t|
      t.string :ip_address
      t.integer :domain_id

      t.timestamps
    end
  end
end
