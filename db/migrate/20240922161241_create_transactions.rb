class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.integer :from_wallet_id
      t.integer :to_wallet_id
      t.decimal :amount
      t.string :transaction_type
      t.datetime :deducted_at

      t.timestamps
    end
  end
end
