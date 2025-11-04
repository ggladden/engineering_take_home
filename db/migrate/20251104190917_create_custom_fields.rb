class CreateCustomFields < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_fields do |t|
      t.string :name, null: false
      t.integer :field_type, null: false
      t.string :enum_options, array: true, default: []
      t.references :client, null: false, foreign_key: true

      t.timestamps

      t.index [ :name, :client_id ], unique: true
    end
  end
end
