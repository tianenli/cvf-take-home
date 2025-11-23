class CohortPaymentSerializer < ActiveModel::Serializer
  attributes :id, :cohort_id, :months_after, :status, :total_revenue, :threshold_hit,
             :share_percentage, :total_owed, :total_paid, :outstanding_amount,
             :payment_percent_of_spend, :finalized_at, :settled_at,
             :created_at, :updated_at

  def outstanding_amount
    object.total_owed - object.total_paid
  end
end
