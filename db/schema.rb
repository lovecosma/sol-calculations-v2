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

ActiveRecord::Schema[8.0].define(version: 2025_12_14_014115) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chart_numbers", force: :cascade do |t|
    t.bigint "chart_id", null: false
    t.bigint "numerology_number_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chart_id"], name: "index_chart_numbers_on_chart_id"
    t.index ["numerology_number_id"], name: "index_chart_numbers_on_numerology_number_id"
  end

  create_table "charts", force: :cascade do |t|
    t.string "full_name", null: false
    t.date "birthdate", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_charts_on_user_id"
  end

  create_table "number_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "numbers", force: :cascade do |t|
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "numerology_numbers", force: :cascade do |t|
    t.bigint "number_id", null: false
    t.bigint "number_type_id", null: false
    t.text "description"
    t.string "primary_title"
    t.string "secondary_titles", default: [], array: true
    t.text "core_essence", default: [], array: true
    t.text "strengths", default: [], array: true
    t.text "challenges", default: [], array: true
    t.text "matches", default: [], array: true
    t.text "mismatches", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "thumbnail_description"
    t.index ["number_id"], name: "index_numerology_numbers_on_number_id"
    t.index ["number_type_id"], name: "index_numerology_numbers_on_number_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chart_numbers", "charts", on_delete: :cascade
  add_foreign_key "chart_numbers", "numerology_numbers", on_delete: :cascade
  add_foreign_key "charts", "users", on_delete: :cascade
  add_foreign_key "numerology_numbers", "number_types", on_delete: :restrict
  add_foreign_key "numerology_numbers", "numbers", on_delete: :restrict
end
