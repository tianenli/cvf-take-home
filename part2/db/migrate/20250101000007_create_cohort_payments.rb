class CreateCohortPayments < ActiveRecord::Migration[7.1]
  def change
    create_table :cohort_payments do |t|
      t.references :cohort, null: false, foreign_key: true

      t.string :status, null: false, default: 'computing'
      t.integer :months_after, null: false

      t.decimal :total_revenue, precision: 15, scale: 2, default: 0
      t.boolean :threshold_hit, default: false
      t.decimal :share_percentage, precision: 5, scale: 2, null: false
      t.decimal :total_owed, precision: 15, scale: 2, default: 0
      t.decimal :total_paid, precision: 15, scale: 2, default: 0

      t.datetime :finalized_at
      t.datetime :settled_at

      t.timestamps
    end

    add_index :cohort_payments, [:cohort_id, :months_after], unique: true
    add_index :cohort_payments, :status
  end
end
