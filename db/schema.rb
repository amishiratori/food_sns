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

ActiveRecord::Schema.define(version: 20170713004607) do

  create_table "calendars", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contributions", force: :cascade do |t|
    t.integer "user_id"
    t.string "rest_name"
    t.string "rest_img"
    t.string "rest_url"
    t.string "memo"
    t.string "who"
    t.integer "year"
    t.integer "month"
    t.integer "day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "friends", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_user_id"
    t.index ["user_id"], name: "index_friends_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "contribution_id"
    t.index ["contribution_id"], name: "index_likes_on_contribution_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "body"
    t.integer "users_id"
    t.integer "rooms_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rooms_id"], name: "index_messages_on_rooms_id"
    t.index ["users_id"], name: "index_messages_on_users_id"
  end

  create_table "rooms", force: :cascade do |t|
  end

  create_table "talkmembers", force: :cascade do |t|
    t.integer "users_id"
    t.integer "rooms_id"
    t.index ["rooms_id"], name: "index_talkmembers_on_rooms_id"
    t.index ["users_id"], name: "index_talkmembers_on_users_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "user_id"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_img"
  end

end
