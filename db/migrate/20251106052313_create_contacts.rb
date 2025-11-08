class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.text :message
      t.integer :inquiry_type

      t.timestamps
    end
  end
end
