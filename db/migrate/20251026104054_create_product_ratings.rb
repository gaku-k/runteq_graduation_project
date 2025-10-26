class CreateProductRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :product_ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :sweet, null: false
      t.integer :spicy, null: false
      t.integer :green, null: false
      t.integer :fruity, null: false
      t.integer :bitter, null: false

      t.timestamps
    end

    # add_indexは指定したテーブルにインデックスを追加する。インデックスを追加するテーブルと、カラムの首合わせも表記
    # unique:true この場合の一意性はuser_idとproduct_idの重複に制約を設けている
    add_index :product_ratings, [ :user_id, :product_id ], unique: true
  end
end
