class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :reference_id, null: false
      t.references :cohort, null: false, foreign_key: true

      t.timestamps
    end

    add_index :customers, [:cohort_id, :reference_id], unique: true
  end
end
