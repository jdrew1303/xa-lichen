# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160717033630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "changes", force: :cascade do |t|
    t.string   "document_id"
    t.integer  "invoice_id"
    t.integer  "rule_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "changes", ["invoice_id"], name: "index_changes_on_invoice_id", using: :btree
  add_index "changes", ["rule_id"], name: "index_changes_on_rule_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string "public_id"
    t.string "event_type"
  end

  create_table "invoice_push_events", force: :cascade do |t|
    t.integer "transaction_id"
    t.integer "event_id"
    t.xml     "content"
    t.string  "transaction_public_id"
  end

  add_index "invoice_push_events", ["event_id"], name: "index_invoice_push_events_on_event_id", using: :btree
  add_index "invoice_push_events", ["transaction_id"], name: "index_invoice_push_events_on_transaction_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer "transact_id"
    t.string  "document_id"
  end

  add_index "invoices", ["transact_id"], name: "index_invoices_on_transact_id", using: :btree

  create_table "rules", force: :cascade do |t|
    t.string  "public_id"
    t.integer "transaction_id"
    t.string  "version"
  end

  add_index "rules", ["transaction_id"], name: "index_rules_on_transaction_id", using: :btree

  create_table "transaction_close_events", force: :cascade do |t|
    t.integer "transaction_id"
    t.integer "event_id"
    t.string  "transaction_public_id"
  end

  add_index "transaction_close_events", ["event_id"], name: "index_transaction_close_events_on_event_id", using: :btree

  create_table "transaction_open_events", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
  end

  add_index "transaction_open_events", ["event_id"], name: "index_transaction_open_events_on_event_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "status"
    t.string   "public_id"
  end

  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "full_name"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "changes", "invoices"
  add_foreign_key "changes", "rules"
  add_foreign_key "invoice_push_events", "events"
  add_foreign_key "invoice_push_events", "transactions"
  add_foreign_key "invoices", "transactions", column: "transact_id"
  add_foreign_key "rules", "transactions"
  add_foreign_key "transaction_close_events", "events"
  add_foreign_key "transaction_open_events", "events"
  add_foreign_key "transactions", "users"
end
