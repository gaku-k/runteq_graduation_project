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

ActiveRecord::Schema[8.1].define(version: 2026_01_03_021315) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.string "ancestry"
    t.text "body"
    t.bigint "commentable_id", null: false
    t.string "commentable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ancestry"], name: "index_comments_on_ancestry"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "inquiry_type"
    t.text "message"
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "like_posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["post_id"], name: "index_like_posts_on_post_id"
    t.index ["user_id", "post_id"], name: "index_like_posts_on_user_id_and_post_id", unique: true
    t.index ["user_id"], name: "index_like_posts_on_user_id"
  end

  create_table "olive_varieties", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_olive_varieties_on_lower_name_not_null", unique: true, where: "(name IS NOT NULL)"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "aroma_rating"
    t.string "body"
    t.datetime "created_at", null: false
    t.integer "price_rating"
    t.bigint "product_id"
    t.string "product_name"
    t.integer "taste_rating"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
  end

  create_table "product_drafts", force: :cascade do |t|
    t.string "country_of_origin"
    t.datetime "created_at", null: false
    t.string "name"
    t.jsonb "new_olive_variety_ids", default: []
    t.jsonb "original_attributes"
    t.jsonb "original_image_blobs"
    t.bigint "product_id"
    t.decimal "reference_price"
    t.integer "request_type", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "volume"
    t.index ["product_id"], name: "index_product_drafts_on_product_id"
    t.index ["user_id"], name: "index_product_drafts_on_user_id"
  end

  create_table "product_olive_varieties", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "olive_variety_id"
    t.bigint "product_draft_id"
    t.integer "product_id"
    t.datetime "updated_at", null: false
    t.index ["product_draft_id"], name: "index_product_olive_varieties_on_product_draft_id"
  end

  create_table "product_ratings", force: :cascade do |t|
    t.integer "aroma"
    t.integer "bitter"
    t.datetime "created_at", null: false
    t.integer "fruity"
    t.integer "green"
    t.integer "price"
    t.bigint "product_id", null: false
    t.integer "spicy"
    t.integer "sweet"
    t.integer "taste"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_product_ratings_on_product_id"
    t.index ["user_id", "product_id"], name: "index_product_ratings_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_ratings_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "country_of_origin"
    t.datetime "created_at", null: false
    t.string "name"
    t.decimal "reference_price"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "volume"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "provider"
    t.string "public_id", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "users"
  add_foreign_key "contacts", "users"
  add_foreign_key "like_posts", "posts"
  add_foreign_key "like_posts", "users"
  add_foreign_key "product_drafts", "products"
  add_foreign_key "product_drafts", "users"
  add_foreign_key "product_olive_varieties", "product_drafts"
  add_foreign_key "product_ratings", "products"
  add_foreign_key "product_ratings", "users"
end
