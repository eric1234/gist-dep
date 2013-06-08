class AddConfig < ActiveRecord::Migration
  def change
    create_table :db_configs do |t|
      t.string :key, null: false
      t.text :value, null: false
    end
  end
end
