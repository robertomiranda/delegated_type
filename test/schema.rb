ActiveRecord::Schema.define do
  create_table :entries, force: true do |t|
    t.string  :entryable_type, null: false
    t.integer :entryable_id, null: false
  end

  create_table :messages, force: true do |t|
    t.string :subject
  end

  create_table :comments, force: true do |t|
    t.text :body
  end
end
