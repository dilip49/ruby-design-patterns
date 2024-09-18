class CreateTableForSingleTableInheritance < ActiveRecord::Migration[7.1]
  create_table "cars", force: :cascade do |t|
		t.string "type"
		t.string "name"
		t.string "model"
		t.integer "price"
		t.integer "company_id", null: false
		t.datetime "created_at", null: false
		t.datetime "updated_at", null: false
		t.index ["company_id"], name: "index_cars_on_company_id"
	end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "cars", "companies"
end
