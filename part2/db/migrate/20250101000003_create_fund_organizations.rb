class CreateFundOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :fund_organizations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :fund, null: false, foreign_key: true

      t.decimal :max_invest_per_cohort, precision: 15, scale: 2
      t.decimal :max_total_invest, precision: 15, scale: 2
      t.date :first_cohort_date
      t.date :last_cohort_date
      t.decimal :default_share_percentage, precision: 5, scale: 2, null: false, default: 0

      # JSON columns for prediction scenarios and thresholds
      t.json :default_prediction_scenarios
      t.json :default_thresholds

      t.timestamps
    end

    add_index :fund_organizations, [:organization_id, :fund_id], unique: true
  end
end
