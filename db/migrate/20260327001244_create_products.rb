class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :sku
      t.decimal :price
      t.integer :stock_quantity
      t.string :size
      t.string :color
      t.string :material
      t.boolean :on_sale
      t.boolean :featured

      t.timestamps
    end
  end
end
