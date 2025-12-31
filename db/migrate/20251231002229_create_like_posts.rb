class CreateLikePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :like_posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
    add_index :like_posts, [ :user_id, :post_id ], unique: true
  end
end
