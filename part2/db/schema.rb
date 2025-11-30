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

ActiveRecord::Schema[7.2].define(version: 2025_11_30_004136) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "cohort_payments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "cohort_id", null: false
    t.string "status", default: "computing", null: false
    t.integer "months_after", null: false
    t.decimal "total_revenue", precision: 15, scale: 2, default: "0.0"
    t.boolean "threshold_hit", default: false
    t.decimal "share_percentage", precision: 5, scale: 2, null: false
    t.decimal "total_owed", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_paid", precision: 15, scale: 2, default: "0.0"
    t.datetime "finalized_at"
    t.datetime "settled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cohort_id", "months_after"], name: "index_cohort_payments_on_cohort_id_and_months_after", unique: true
    t.index ["cohort_id"], name: "index_cohort_payments_on_cohort_id"
    t.index ["status"], name: "index_cohort_payments_on_status"
  end

  create_table "cohorts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "fund_organization_id", null: false
    t.date "cohort_start_date", null: false
    t.decimal "share_percentage", precision: 5, scale: 2
    t.string "status", default: "new", null: false
    t.json "prediction_scenarios_override"
    t.json "thresholds_override"
    t.decimal "planned_spend", precision: 15, scale: 2, default: "0.0"
    t.decimal "actual_spend", precision: 15, scale: 2
    t.decimal "cash_cap", precision: 15, scale: 2
    t.decimal "total_returned", precision: 15, scale: 2, default: "0.0"
    t.datetime "approved_at"
    t.datetime "completed_at"
    t.datetime "settled_at"
    t.datetime "terminated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "min_allowed_spend", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "max_allowed_spend", precision: 15, scale: 2
    t.decimal "adjusted_cash_cap", precision: 15, scale: 2
    t.index ["cohort_start_date"], name: "index_cohorts_on_cohort_start_date"
    t.index ["fund_organization_id", "cohort_start_date"], name: "index_cohorts_on_fund_org_and_start_date", unique: true
    t.index ["fund_organization_id"], name: "index_cohorts_on_fund_organization_id"
    t.index ["status"], name: "index_cohorts_on_status"
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "reference_id", null: false
    t.bigint "cohort_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cohort_id", "reference_id"], name: "index_customers_on_cohort_id_and_reference_id", unique: true
    t.index ["cohort_id"], name: "index_customers_on_cohort_id"
  end

  create_table "dashboard_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "organization_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.index ["email"], name: "index_dashboard_users_on_email", unique: true
    t.index ["jti"], name: "index_dashboard_users_on_jti", unique: true
    t.index ["organization_id"], name: "index_dashboard_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_dashboard_users_on_reset_password_token", unique: true
  end

  create_table "fund_organizations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "fund_id", null: false
    t.decimal "max_invest_per_cohort", precision: 15, scale: 2
    t.decimal "max_total_invest", precision: 15, scale: 2
    t.date "first_cohort_date"
    t.date "last_cohort_date"
    t.decimal "default_share_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.json "default_prediction_scenarios"
    t.json "default_thresholds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fund_id"], name: "index_fund_organizations_on_fund_id"
    t.index ["organization_id", "fund_id"], name: "index_fund_organizations_on_organization_id_and_fund_id", unique: true
    t.index ["organization_id"], name: "index_fund_organizations_on_organization_id"
  end

  create_table "funds", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_funds_on_name"
    t.index ["start_date"], name: "index_funds_on_start_date"
  end

  create_table "organizations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organizations_on_name"
  end

  create_table "transaction_uploads", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "status", default: "submitted", null: false
    t.text "error_message"
    t.integer "total_rows"
    t.integer "processed_rows"
    t.integer "failed_rows"
    t.datetime "processing_started_at"
    t.datetime "processing_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "error_details"
    t.index ["created_at"], name: "index_transaction_uploads_on_created_at"
    t.index ["organization_id"], name: "index_transaction_uploads_on_organization_id"
    t.index ["status"], name: "index_transaction_uploads_on_status"
  end

  create_table "txns", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "customer_id", null: false
    t.string "reference_id", null: false
    t.date "payment_date", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_txns_on_customer_id"
    t.index ["organization_id", "reference_id"], name: "index_txns_on_organization_id_and_reference_id", unique: true
    t.index ["organization_id"], name: "index_txns_on_organization_id"
    t.index ["payment_date"], name: "index_txns_on_payment_date"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cohort_payments", "cohorts"
  add_foreign_key "cohorts", "fund_organizations"
  add_foreign_key "customers", "cohorts"
  add_foreign_key "dashboard_users", "organizations"
  add_foreign_key "fund_organizations", "funds"
  add_foreign_key "fund_organizations", "organizations"
  add_foreign_key "transaction_uploads", "organizations"
  add_foreign_key "txns", "customers"
  add_foreign_key "txns", "organizations"
end
