class CohortSerializer < ActiveModel::Serializer
  attributes :id, :fund_organization_id, :cohort_start_date, :status, :share_percentage,
             :planned_spend, :actual_spend, :min_allowed_spend, :max_allowed_spend,
             :cash_cap, :total_returned,
             :approved_at, :completed_at, :settled_at, :terminated_at,
             :created_at, :updated_at, :progress_percentage

  def progress_percentage
    return 0 if object.cash_cap.nil? || object.cash_cap.zero?
    ((object.total_returned / object.cash_cap) * 100).round(2)
  end
end
