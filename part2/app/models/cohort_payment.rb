class CohortPayment < ApplicationRecord
  include AASM

  # Associations
  belongs_to :cohort

  # Validations
  validates :months_after, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :months_after, uniqueness: { scope: :cohort_id }
  validates :share_percentage, presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :total_revenue, numericality: { greater_than_or_equal_to: 0 }
  validates :total_owed, numericality: { greater_than_or_equal_to: 0 }
  validates :total_paid, numericality: { greater_than_or_equal_to: 0 }

  # Delegations
  delegate :organization, to: :cohort
  delegate :fund_organization, to: :cohort

  # Callbacks
  before_validation :set_defaults, on: :create
  after_save :update_cohort_total_returned

  # Scopes
  scope :for_months_after, ->(months) { where(months_after: months) }
  scope :overdue, -> { where(status: 'finalized').where('total_paid < total_owed') }

  # AASM State Machine
  aasm column: :status do
    state :computing, initial: true
    state :finalized
    state :settled

    event :finalize do
      transitions from: :computing, to: :finalized, after: :set_finalized_at
    end

    event :settle do
      transitions from: :finalized, to: :settled, after: :set_settled_at
    end

    event :recompute do
      transitions from: [:finalized, :settled], to: :computing
    end
  end

  def calculate_revenue!
    self.total_revenue = cohort.txns
      .joins(:customer)
      .where('txns.payment_date >= ? AND txns.payment_date < ?',
             cohort.cohort_start_date + months_after.months,
             cohort.cohort_start_date + (months_after + 1).months)
      .sum(:amount)
  end

  def calculate_threshold_hit!
    threshold = cohort.thresholds.find { |t| t.payment_period_month == months_after }
    return if threshold.nil?

    spend = cohort.actual_spend
    return if spend.zero?

    payment_percent = total_revenue / spend
    self.threshold_hit = payment_percent < threshold.minimum_payment_percent
  end

  def calculate_share_percentage!
    self.share_percentage = threshold_hit ? 100.0 : cohort.share_percentage
  end

  def calculate_total_owed!
    # Check if cohort has reached cash cap
    if cohort.total_returned >= cohort.cash_cap
      self.total_owed = 0
    else
      base_owed = total_revenue * (share_percentage / 100.0)
      remaining_cap = cohort.cash_cap - cohort.total_returned

      # Don't collect more than remaining cap
      self.total_owed = [base_owed, remaining_cap].min
    end
  end

  def payment_percent_of_spend
    return 0 if cohort.actual_spend.nil? || cohort.actual_spend.zero?
    (total_revenue / cohort.actual_spend * 100).round(2)
  end

  private

  def set_defaults
    self.total_revenue ||= 0
    self.total_owed ||= 0
    self.total_paid ||= 0
    self.threshold_hit ||= false
    self.share_percentage ||= cohort.share_percentage
  end

  def set_finalized_at
    self.finalized_at = Time.current
  end

  def set_settled_at
    self.settled_at = Time.current
    self.total_paid = total_owed
  end

  def update_cohort_total_returned
    return unless saved_change_to_total_paid?

    cohort.update!(total_returned: cohort.cohort_payments.sum(:total_paid))

    # Check if cohort should be settled
    if cohort.total_returned >= cohort.cash_cap && cohort.may_settle?
      cohort.settle!
    end
  end
end
