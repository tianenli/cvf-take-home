class CreateTxns < ActiveRecord::Migration[7.1]
  def change
    create_table :txns do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true

      t.string :reference_id, null: false
      t.date :payment_date, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false

      t.timestamps
    end

    add_index :txns, [:organization_id, :reference_id], unique: true
    add_index :txns, :payment_date
    add_index :txns, :customer_id
  end
end
