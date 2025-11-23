class Txn < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :customer

  # Validations
  validates :reference_id, presence: true
  validates :reference_id, uniqueness: { scope: :organization_id }
  validates :payment_date, presence: true
  validates :amount, presence: true, numericality: true

  # Callbacks
  after_create :update_cohort_payment
  after_destroy :update_cohort_payment

  # Delegations
  delegate :cohort, to: :customer

  # Scopes
  scope :for_cohort, ->(cohort) { joins(:customer).where(customers: { cohort_id: cohort.id }) }
  scope :for_month, ->(date) { where(payment_date: date.beginning_of_month..date.end_of_month) }

  def months_after_cohort
    cohort_start = customer.cohort.cohort_start_date
    ((payment_date.year - cohort_start.year) * 12) + (payment_date.month - cohort_start.month)
  end

  private

  def update_cohort_payment
    UpdateCohortPaymentJob.perform_async(customer.cohort_id, months_after_cohort)
  end
end
