class AddUniqueIndexToOliveVarietiesName < ActiveRecord::Migration[8.0]
  def change
    # LOWER(name): 全てのnameを小文字に変換した値でインデックスを構築。大文字・小文字を無視して重複をチェックできる
    # unique: true: 重複を禁止
    # where: 'name IS NOT NULL': nameがNULLのレコードはインデックスの対象外となり、いくつでも作成を許可
    add_index :olive_varieties, 'LOWER(name)', unique: true,
              where: 'name IS NOT NULL',
              name: 'index_olive_varieties_on_lower_name_not_null'
  end
end
