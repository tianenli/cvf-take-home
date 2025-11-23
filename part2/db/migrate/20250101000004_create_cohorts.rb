class CreateCohorts < ActiveRecord::Migration[7.1]
  def change
    create_table :cohorts do |t|
      t.references :fund_organization, null: false, foreign_key: true

      t.date :cohort_start_date, null: false
      t.decimal :share_percentage, precision: 5, scale: 2, null: false
      t.string :status, null: false, default: 'new'

      # Override fields
      t.json :prediction_scenarios_override
      t.json :thresholds_override

      # Financial fields
      t.decimal :committed, precision: 15, scale: 2, default: 0
      t.decimal :adjustment, precision: 15, scale: 2
      t.decimal :cash_cap, precision: 15, scale: 2, null: false
      t.decimal :total_returned, precision: 15, scale: 2, default: 0

      # Timestamp fields for state transitions
      t.datetime :approved_at
      t.datetime :completed_at
      t.datetime :settled_at
      t.datetime :terminated_at

      t.timestamps
    end

    add_index :cohorts, [:fund_organization_id, :cohort_start_date], unique: true, name: 'index_cohorts_on_fund_org_and_start_date'
    add_index :cohorts, :status
    add_index :cohorts, :cohort_start_date
  end
end
