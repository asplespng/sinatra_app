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

ActiveRecord::Schema.define(version: 20160608154321) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string  "email"
    t.string  "password_digest"
    t.boolean "confirmed",            default: false
    t.string  "confirm_token"
    t.string  "name"
    t.string  "uid"
    t.string  "auth_provider"
    t.string  "password_reset_token"
  end

  add_index "users", ["uid", "auth_provider"], name: "index_users_on_uid_and_auth_provider", unique: true, using: :btree

end
