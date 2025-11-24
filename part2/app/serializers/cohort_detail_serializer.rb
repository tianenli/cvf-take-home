class CohortDetailSerializer < ActiveModel::Serializer
  attributes :id, :fund_organization_id, :cohort_start_date, :status, :share_percentage,
             :planned_spend, :actual_spend, :min_allowed_spend, :max_allowed_spend,
             :cash_cap, :adjusted_cash_cap, :effective_cash_cap, :total_returned,
             :prediction_scenarios, :thresholds,
             :approved_at, :completed_at, :settled_at, :terminated_at,
             :created_at, :updated_at, :progress_percentage, :organization_name, :fund_name

  has_many :cohort_payments

  def effective_cash_cap
    object.effective_cash_cap
  end

  def progress_percentage
    return 0 if object.effective_cash_cap.nil? || object.effective_cash_cap.zero?
    ((object.total_returned / object.effective_cash_cap) * 100).round(2)
  end

  def organization_name
    object.organization.name
  end

  def fund_name
    object.fund.name
  end
end
