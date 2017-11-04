class CreateDomains < ActiveRecord::Migration[5.1]
  def change
    create_table :domains do |t|
      t.integer :user_id
      t.string :domain_name

      t.timestamps
    end
  end
end