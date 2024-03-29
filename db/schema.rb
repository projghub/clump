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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121012163321) do

  create_table "lead_exports", :force => true do |t|
    t.integer  "lead_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "leads", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "gender"
    t.string   "date_of_birth"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "region"
    t.string   "postal_code"
    t.string   "country"
    t.string   "phone"
    t.string   "email"
    t.string   "offer_id"
    t.string   "pub_id"
    t.string   "sub_id"
    t.string   "url"
    t.string   "ip_address"
    t.datetime "acquired_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
