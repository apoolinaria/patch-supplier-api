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

ActiveRecord::Schema[8.1].define(version: 2026_05_17_200307) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "fulfillment_proofs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mass_g", null: false
    t.bigint "offset_id", null: false
    t.string "serial_number", null: false
    t.datetime "updated_at", null: false
    t.index ["offset_id"], name: "index_fulfillment_proofs_on_offset_id"
    t.index ["serial_number"], name: "index_fulfillment_proofs_on_serial_number", unique: true
  end

  create_table "offsets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mass_g", null: false
    t.integer "price_cents_usd", null: false
    t.bigint "project_id", null: false
    t.boolean "retired", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_offsets_on_project_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mass_g", null: false
    t.bigint "offset_id", null: false
    t.datetime "updated_at", null: false
    t.index ["offset_id"], name: "index_orders_on_offset_id"
  end

  create_table "payouts", force: :cascade do |t|
    t.integer "amount_cents_usd", null: false
    t.datetime "created_at", null: false
    t.bigint "offset_id", null: false
    t.bigint "project_id", null: false
    t.string "status", default: "pending_approval", null: false
    t.datetime "updated_at", null: false
    t.index ["offset_id"], name: "index_payouts_on_offset_id", unique: true
    t.index ["project_id"], name: "index_payouts_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_projects_on_api_key", unique: true
  end

  add_foreign_key "fulfillment_proofs", "offsets"
  add_foreign_key "offsets", "projects"
  add_foreign_key "orders", "offsets"
  add_foreign_key "payouts", "offsets"
  add_foreign_key "payouts", "projects"
end
