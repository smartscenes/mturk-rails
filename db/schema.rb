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

ActiveRecord::Schema.define(version: 20150814173559) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "identities", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mt_assignments", force: :cascade do |t|
    t.string "mtId"
    t.integer "mt_hit_id"
    t.integer "mt_worker_id"
    t.text "data", limit: 16777215
    t.datetime "completed_at"
    t.string "coupon_code"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["completed_at"], name: "index_mt_assignments_on_completed_at"
    t.index ["created_at"], name: "index_mt_assignments_on_created_at"
    t.index ["mtId", "mt_hit_id", "mt_worker_id"], name: "index_mt_assignments_on_mtId_and_mt_hit_id_and_mt_worker_id"
    t.index ["status"], name: "index_mt_assignments_on_status"
    t.index ["updated_at"], name: "index_mt_assignments_on_updated_at"
  end

  create_table "mt_completed_items", force: :cascade do |t|
    t.integer "mt_task_id"
    t.integer "mt_worker_id"
    t.integer "mt_hit_id"
    t.integer "mt_assignment_id"
    t.string "mt_condition"
    t.string "mt_item"
    t.text "data", limit: 16777215
    t.string "status"
    t.string "preview_uid"
    t.string "preview_name"
    t.string "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_at"], name: "index_mt_completed_items_on_created_at"
    t.index ["mt_assignment_id"], name: "index_mt_completed_items_on_mt_assignment_id"
    t.index ["mt_condition"], name: "index_mt_completed_items_on_mt_condition"
    t.index ["mt_hit_id"], name: "index_mt_completed_items_on_mt_hit_id"
    t.index ["mt_item"], name: "index_mt_completed_items_on_mt_item"
    t.index ["mt_task_id"], name: "index_mt_completed_items_on_mt_task_id"
    t.index ["mt_worker_id"], name: "index_mt_completed_items_on_mt_worker_id"
    t.index ["status"], name: "index_mt_completed_items_on_status"
    t.index ["updated_at"], name: "index_mt_completed_items_on_updated_at"
  end

  create_table "mt_hits", force: :cascade do |t|
    t.string "mtId"
    t.integer "mt_task_id"
    t.datetime "completed_at"
    t.text "conf", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["mtId"], name: "index_mt_hits_on_mtId"
    t.index ["mt_task_id"], name: "index_mt_hits_on_mt_task_id"
  end

  create_table "mt_tasks", force: :cascade do |t|
    t.string "name"
    t.datetime "submitted_at"
    t.datetime "completed_at"
    t.string "title"
    t.text "description"
    t.integer "reward"
    t.integer "num_assignments"
    t.integer "max_workers"
    t.integer "max_hits_per_worker"
    t.string "keywords"
    t.integer "shelf_life"
    t.integer "max_task_time"
    t.integer "user_id"
    t.string "controller"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["controller"], name: "index_mt_tasks_on_controller"
    t.index ["created_at"], name: "index_mt_tasks_on_created_at"
    t.index ["name"], name: "index_mt_tasks_on_name"
  end

  create_table "mt_workers", force: :cascade do |t|
    t.string "mtId"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["mtId"], name: "index_mt_workers_on_mtId"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
