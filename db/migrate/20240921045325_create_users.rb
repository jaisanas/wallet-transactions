class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name
      t.datetime :birth_date
      t.string :email
      t.string :phone_number
      t.string :password_digest
      t.string :address
      t.string :user_type
      t.references :sateam, null: true, foreign_key: true
      t.timestamps
    end
  end
end
