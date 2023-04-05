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

ActiveRecord::Schema.define(version: 2023_04_05_011057) do

  create_table "approvals", force: :cascade do |t|
    t.integer "value"
    t.text "note"
    t.integer "option_id", null: false
    t.integer "decision_id", null: false
    t.integer "created_by_id", null: false
    t.integer "team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_id"], name: "index_approvals_on_created_by_id"
    t.index ["decision_id"], name: "index_approvals_on_decision_id"
    t.index ["option_id"], name: "index_approvals_on_option_id"
    t.index ["team_id"], name: "index_approvals_on_team_id"
  end

  create_table "decisions", force: :cascade do |t|
    t.text "context"
    t.text "question"
    t.string "status"
    t.datetime "deadline", precision: 6
    t.integer "created_by_id", null: false
    t.integer "team_id", null: false
    t.json "external_ids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.index ["created_by_id"], name: "index_decisions_on_created_by_id"
    t.index ["team_id"], name: "index_decisions_on_team_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "revoked_at", precision: 6
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "revoked_at", precision: 6
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "owner_id"
    t.index ["owner_id"], name: "index_oauth_applications_on_owner_id"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "options", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.integer "created_by_id", null: false
    t.integer "decision_id", null: false
    t.integer "team_id", null: false
    t.json "external_ids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_id"], name: "index_options_on_created_by_id"
    t.index ["decision_id"], name: "index_options_on_decision_id"
    t.index ["team_id"], name: "index_options_on_team_id"
  end

  create_table "team_members", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.integer "team_id", null: false
    t.integer "user_id", null: false
    t.json "external_ids"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "handle"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "webhooks", force: :cascade do |t|
    t.string "url"
    t.string "secret"
    t.string "event"
    t.integer "team_id", null: false
    t.integer "decision_id"
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_id"], name: "index_webhooks_on_created_by_id"
    t.index ["decision_id"], name: "index_webhooks_on_decision_id"
    t.index ["team_id"], name: "index_webhooks_on_team_id"
  end

  add_foreign_key "approvals", "decisions"
  add_foreign_key "approvals", "options"
  add_foreign_key "approvals", "teams"
  add_foreign_key "decisions", "teams"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_applications", "users", column: "owner_id"
  add_foreign_key "options", "decisions"
  add_foreign_key "options", "teams"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "webhooks", "decisions"
  add_foreign_key "webhooks", "teams"
  add_foreign_key "webhooks", "users", column: "created_by_id"
end
