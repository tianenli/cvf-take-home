class FundOrganizationSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :fund_id, :max_invest_per_cohort, :max_total_invest,
             :first_cohort_date, :last_cohort_date, :default_share_percentage,
             :default_prediction_scenarios, :default_thresholds, :total_invested, :remaining_capacity

  belongs_to :organization
  belongs_to :fund
end
