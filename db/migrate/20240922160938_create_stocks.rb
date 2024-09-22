class CreateStocks < ActiveRecord::Migration[7.2]
  def change
    create_table :stocks do |t|
      t.string :name
      t.decimal :price_per_unit, precision: 10, scale: 2
      t.string :description
      t.string :status

      t.timestamps
    end
  end
end
