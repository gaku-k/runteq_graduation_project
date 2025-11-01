# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_31_235545) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "olive_varieties", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_olive_varieties_on_lower_name_not_null", unique: true, where: "(name IS NOT NULL)"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "product_id"
    t.string "product_name"
    t.integer "aroma_rating"
    t.integer "taste_rating"
    t.integer "price_rating"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_drafts", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.string "name"
    t.string "country_of_origin"
    t.integer "volume"
    t.decimal "reference_price"
    t.integer "request_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "original_attributes"
    t.jsonb "original_image_blobs"
    t.jsonb "new_olive_variety_ids", default: []
    t.index ["product_id"], name: "index_product_drafts_on_product_id"
    t.index ["user_id"], name: "index_product_drafts_on_user_id"
  end

  create_table "product_olive_varieties", force: :cascade do |t|
    t.integer "product_id"
    t.integer "olive_variety_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_draft_id"
    t.index ["product_draft_id"], name: "index_product_olive_varieties_on_product_draft_id"
  end

  create_table "product_ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "sweet"
    t.integer "spicy"
    t.integer "green"
    t.integer "fruity"
    t.integer "bitter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_ratings_on_product_id"
    t.index ["user_id", "product_id"], name: "index_product_ratings_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_ratings_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "country_of_origin"
    t.integer "volume"
    t.decimal "reference_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "product_drafts", "products"
  add_foreign_key "product_drafts", "users"
  add_foreign_key "product_olive_varieties", "product_drafts"
  add_foreign_key "product_ratings", "products"
  add_foreign_key "product_ratings", "users"
end
