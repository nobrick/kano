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

ActiveRecord::Schema.define(version: 20150916152301) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "phone"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin",                  default: false, null: false
    t.integer  "coins",                  default: 0,     null: false
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname"
    t.string   "gender"
    t.string   "wechat_headimgurl"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                   null: false
  end

  add_index "accounts", ["admin"], name: "index_accounts_on_admin", using: :btree
  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["gender"], name: "index_accounts_on_gender", using: :btree
  add_index "accounts", ["name"], name: "index_accounts_on_name", using: :btree
  add_index "accounts", ["phone"], name: "index_accounts_on_phone", unique: true, using: :btree
  add_index "accounts", ["provider"], name: "index_accounts_on_provider", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  add_index "accounts", ["uid"], name: "index_accounts_on_uid", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",                                               null: false
    t.integer  "handyman_id"
    t.string   "taxon_code",           limit: 30,                       null: false
    t.string   "content",                                               null: false
    t.datetime "arrives_at",                                            null: false
    t.datetime "contracted_at"
    t.datetime "completed_at"
    t.decimal  "user_total"
    t.decimal  "payment_total"
    t.decimal  "user_promo_total"
    t.decimal  "handyman_bonus_total"
    t.decimal  "handyman_total"
    t.integer  "transferee_order_id"
    t.string   "transfer_type",        limit: 30
    t.string   "transfer_reason"
    t.datetime "transferred_at"
    t.integer  "transferor_id"
    t.string   "cancel_type",          limit: 30
    t.string   "cancel_reason"
    t.datetime "canceled_at"
    t.integer  "canceler_id"
    t.integer  "rating"
    t.string   "rating_content"
    t.datetime "rated_at"
    t.string   "report_type",          limit: 30
    t.string   "report_content"
    t.datetime "reported_at"
    t.string   "state",                           default: "requested", null: false
    t.string   "payment_state",                   default: "initial",   null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "orders", ["arrives_at"], name: "index_orders_on_arrives_at", using: :btree
  add_index "orders", ["cancel_type"], name: "index_orders_on_cancel_type", using: :btree
  add_index "orders", ["canceled_at"], name: "index_orders_on_canceled_at", using: :btree
  add_index "orders", ["canceler_id"], name: "index_orders_on_canceler_id", using: :btree
  add_index "orders", ["completed_at"], name: "index_orders_on_completed_at", using: :btree
  add_index "orders", ["contracted_at"], name: "index_orders_on_contracted_at", using: :btree
  add_index "orders", ["handyman_bonus_total"], name: "index_orders_on_handyman_bonus_total", using: :btree
  add_index "orders", ["handyman_id"], name: "index_orders_on_handyman_id", using: :btree
  add_index "orders", ["handyman_total"], name: "index_orders_on_handyman_total", using: :btree
  add_index "orders", ["payment_state"], name: "index_orders_on_payment_state", using: :btree
  add_index "orders", ["payment_total"], name: "index_orders_on_payment_total", using: :btree
  add_index "orders", ["rated_at"], name: "index_orders_on_rated_at", using: :btree
  add_index "orders", ["rating"], name: "index_orders_on_rating", using: :btree
  add_index "orders", ["report_type"], name: "index_orders_on_report_type", using: :btree
  add_index "orders", ["reported_at"], name: "index_orders_on_reported_at", using: :btree
  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree
  add_index "orders", ["taxon_code"], name: "index_orders_on_taxon_code", using: :btree
  add_index "orders", ["transfer_type"], name: "index_orders_on_transfer_type", using: :btree
  add_index "orders", ["transferee_order_id"], name: "index_orders_on_transferee_order_id", using: :btree
  add_index "orders", ["transferor_id"], name: "index_orders_on_transferor_id", using: :btree
  add_index "orders", ["transferred_at"], name: "index_orders_on_transferred_at", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree
  add_index "orders", ["user_promo_total"], name: "index_orders_on_user_promo_total", using: :btree
  add_index "orders", ["user_total"], name: "index_orders_on_user_total", using: :btree

  add_foreign_key "orders", "accounts", column: "canceler_id"
  add_foreign_key "orders", "accounts", column: "handyman_id"
  add_foreign_key "orders", "accounts", column: "transferor_id"
  add_foreign_key "orders", "accounts", column: "user_id"
end
