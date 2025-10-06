class CreateOliveVarieties < ActiveRecord::Migration[8.0]
  def change
    create_table :olive_varieties do |t|
      t.string :name

      t.timestamps
    end
  end
end
