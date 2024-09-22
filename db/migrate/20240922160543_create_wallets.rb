class CreateWallets < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets do |t|
      t.decimal :balance, precision: 10, scale: 2
      t.string :currency
      t.references :wallet_type, polymorphic: true, null: false

      t.timestamps
    end
  end
end
