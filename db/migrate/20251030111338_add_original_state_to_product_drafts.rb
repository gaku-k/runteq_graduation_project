class AddOriginalStateToProductDrafts < ActiveRecord::Migration[8.0]
  def change
    add_column :product_drafts, :original_attributes, :jsonb
    add_column :product_drafts, :original_image_blobs, :jsonb
  end
end
