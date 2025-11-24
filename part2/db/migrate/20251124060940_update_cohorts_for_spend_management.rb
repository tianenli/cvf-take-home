class UpdateCohortsForSpendManagement < ActiveRecord::Migration[7.2]
  def change
    # Rename columns to reflect spend management workflow
    rename_column :cohorts, :committed, :planned_spend
    rename_column :cohorts, :adjustment, :actual_spend

    # Add columns for spend validation ranges
    add_column :cohorts, :min_allowed_spend, :decimal, precision: 15, scale: 2, default: 0, null: false
    add_column :cohorts, :max_allowed_spend, :decimal, precision: 15, scale: 2
  end
end
