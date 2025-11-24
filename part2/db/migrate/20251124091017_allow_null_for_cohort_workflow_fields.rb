class AllowNullForCohortWorkflowFields < ActiveRecord::Migration[7.2]
  def change
    change_column_null :cohorts, :share_percentage, true
    change_column_null :cohorts, :cash_cap, true
  end
end
