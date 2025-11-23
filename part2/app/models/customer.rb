class Customer < ApplicationRecord
  # Associations
  belongs_to :cohort
  has_many :txns, dependent: :restrict_with_error

  # Validations
  validates :reference_id, presence: true
  validates :reference_id, uniqueness: { scope: :cohort_id }

  # Delegations
  delegate :organization, to: :cohort
  delegate :fund_organization, to: :cohort

  def total_payments
    txns.sum(:amount)
  end

  def payments_by_month
    txns.group_by { |t| t.payment_date.beginning_of_month }
      .transform_values { |txns| txns.sum(&:amount) }
  end
end
