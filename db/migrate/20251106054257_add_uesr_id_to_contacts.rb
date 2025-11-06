class AddUesrIdToContacts < ActiveRecord::Migration[8.1]
  def change
    add_reference :contacts, :user, foreign_key: true, null: true
  end
end
