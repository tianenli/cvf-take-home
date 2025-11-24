class AddAdjustedCashCapToCohorts < ActiveRecord::Migration[7.2]
  def change
    add_column :cohorts, :adjusted_cash_cap, :decimal, precision: 15, scale: 2
  end
end
