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

ActiveRecord::Schema.define(version: 20151219043240) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email"
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
    t.integer  "primary_address_id"
  end

  add_index "accounts", ["admin"], name: "index_accounts_on_admin", using: :btree
  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, where: "(email IS NOT NULL)", using: :btree
  add_index "accounts", ["gender"], name: "index_accounts_on_gender", using: :btree
  add_index "accounts", ["name"], name: "index_accounts_on_name", using: :btree
  add_index "accounts", ["phone"], name: "index_accounts_on_phone", unique: true, where: "(phone IS NOT NULL)", using: :btree
  add_index "accounts", ["primary_address_id"], name: "index_accounts_on_primary_address_id", using: :btree
  add_index "accounts", ["provider", "uid"], name: "index_accounts_on_provider_and_uid", unique: true, where: "(uid IS NOT NULL)", using: :btree
  add_index "accounts", ["provider"], name: "index_accounts_on_provider", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  add_index "accounts", ["uid"], name: "index_accounts_on_uid", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "addressable_id",              null: false
    t.string   "addressable_type",            null: false
    t.string   "province",         limit: 20, null: false
    t.string   "city",             limit: 20, null: false
    t.string   "district",         limit: 20, null: false
    t.string   "code",             limit: 10, null: false
    t.string   "content",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "addresses", ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id", using: :btree
  add_index "addresses", ["code"], name: "index_addresses_on_code", using: :btree
  add_index "addresses", ["province", "city", "district"], name: "index_addresses_on_province_and_city_and_district", using: :btree

  create_table "balance_records", force: :cascade do |t|
    t.decimal  "balance",               precision: 12, scale: 2,                 null: false
    t.decimal  "previous_balance",      precision: 12, scale: 2,                 null: false
    t.decimal  "cash_total",            precision: 12, scale: 2,                 null: false
    t.decimal  "previous_cash_total",   precision: 12, scale: 2,                 null: false
    t.decimal  "adjustment",            precision: 12, scale: 2,                 null: false
    t.integer  "owner_id",                                                       null: false
    t.string   "owner_type",                                                     null: false
    t.integer  "adjustment_event_id",                                            null: false
    t.string   "adjustment_event_type",                                          null: false
    t.boolean  "in_cash",                                        default: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "balance_records", ["adjustment_event_id", "adjustment_event_type"], name: "index_balance_records_on_adjustment_event", unique: true, using: :btree
  add_index "balance_records", ["created_at"], name: "index_balance_records_on_created_at", using: :btree
  add_index "balance_records", ["in_cash"], name: "index_balance_records_on_in_cash", using: :btree
  add_index "balance_records", ["owner_id", "owner_type"], name: "index_balance_records_on_owner", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",                                                   null: false
    t.integer  "handyman_id"
    t.string   "taxon_code",           limit: 128,                          null: false
    t.string   "content",                                                   null: false
    t.datetime "arrives_at",                                                null: false
    t.datetime "contracted_at"
    t.datetime "completed_at"
    t.decimal  "user_total",                       precision: 12, scale: 2
    t.decimal  "payment_total",                    precision: 12, scale: 2
    t.decimal  "user_promo_total",                 precision: 12, scale: 2
    t.decimal  "handyman_bonus_total",             precision: 12, scale: 2
    t.decimal  "handyman_total",                   precision: 12, scale: 2
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
    t.string   "state",                                                     null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
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
  add_index "orders", ["payment_total"], name: "index_orders_on_payment_total", using: :btree
  add_index "orders", ["rated_at"], name: "index_orders_on_rated_at", using: :btree
  add_index "orders", ["rating"], name: "index_orders_on_rating", using: :btree
  add_index "orders", ["report_type"], name: "index_orders_on_report_type", using: :btree
  add_index "orders", ["reported_at"], name: "index_orders_on_reported_at", using: :btree
  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree
  add_index "orders", ["taxon_code"], name: "index_orders_on_taxon_code", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree
  add_index "orders", ["user_promo_total"], name: "index_orders_on_user_promo_total", using: :btree
  add_index "orders", ["user_total"], name: "index_orders_on_user_total", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id",                        null: false
    t.string   "payment_method",       limit: 32, null: false
    t.datetime "expires_at",                      null: false
    t.string   "state",                limit: 32, null: false
    t.inet     "last_ip"
    t.integer  "payment_profile_id"
    t.string   "payment_profile_type"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree
  add_index "payments", ["payment_method"], name: "index_payments_on_payment_method", using: :btree
  add_index "payments", ["payment_profile_type", "payment_profile_id"], name: "index_payments_on_payment_profile_type_and_payment_profile_id", using: :btree
  add_index "payments", ["state"], name: "index_payments_on_state", using: :btree

  create_table "taxons", force: :cascade do |t|
    t.integer  "handyman_id",             null: false
    t.string   "code",        limit: 128, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "taxons", ["handyman_id", "code"], name: "index_taxons_on_handyman_id_and_code", unique: true, using: :btree
  add_index "taxons", ["handyman_id"], name: "index_taxons_on_handyman_id", using: :btree

  add_foreign_key "accounts", "addresses", column: "primary_address_id"
  add_foreign_key "orders", "accounts", column: "canceler_id"
  add_foreign_key "orders", "accounts", column: "handyman_id"
  add_foreign_key "orders", "accounts", column: "user_id"
  add_foreign_key "payments", "orders"
  add_foreign_key "taxons", "accounts", column: "handyman_id"
end
