class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :commentable, polymorphic: true, null: false
      t.text :body
      t.string :ancestry

      t.timestamps
    end
    add_index :comments, :ancestry
  end
end
