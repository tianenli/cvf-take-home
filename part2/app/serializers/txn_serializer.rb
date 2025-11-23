class TxnSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :customer_id, :reference_id, :payment_date, :amount,
             :months_after_cohort, :created_at, :updated_at

  belongs_to :customer
end
