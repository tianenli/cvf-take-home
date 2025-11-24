class Cohort < ApplicationRecord
  include AASM

  # Associations
  belongs_to :fund_organization
  has_many :customers, dependent: :restrict_with_error
  has_many :cohort_payments, dependent: :destroy
  has_many :txns, through: :customers

  # Delegations
  delegate :organization, to: :fund_organization
  delegate :fund, to: :fund_organization

  # StoreModel for JSON columns
  attribute :prediction_scenarios_override, PredictionScenario.to_array_type
  attribute :thresholds_override, Threshold.to_array_type

  # Validations
  validates :cohort_start_date, presence: true
  validates :cohort_start_date, uniqueness: { scope: :fund_organization_id }
  validates :share_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :cash_cap, numericality: { greater_than: 0 }, allow_nil: true
  validates :planned_spend, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :actual_spend, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_returned, numericality: { greater_than_or_equal_to: 0 }
  validates :min_allowed_spend, numericality: { greater_than_or_equal_to: 0 }
  validates :max_allowed_spend, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_validation :set_defaults, on: :create
  after_save :recalculate_cohort_payments, if: :saved_change_to_actual_spend?

  # Scopes
  scope :active_cohorts, -> { where(status: ['active', 'completed']) }
  scope :for_date, ->(date) { where(cohort_start_date: date) }

  # AASM State Machine
  aasm column: :status do
    state :new, initial: true
    state :submitted
    state :pending_approval
    state :approved
    state :pending_review
    state :completed
    state :settled
    state :terminated

    event :submit do
      transitions from: :new, to: :submitted, after: :generate_investment_proposal
    end

    event :approve do
      transitions from: :pending_approval, to: :approved, after: :set_approved_at
    end

    event :complete do
      transitions from: :approved, to: :completed, after: :set_completed_at, guard: :actual_spend_in_range?
    end

    event :flag_for_review do
      transitions from: :approved, to: :pending_review, guard: :actual_spend_out_of_range?
    end

    event :settle do
      transitions from: [:approved, :completed, :pending_review], to: :settled, after: :set_settled_at
    end

    event :terminate do
      transitions from: [:approved, :completed, :pending_review], to: :terminated, after: :set_terminated_at
    end
  end

  def prediction_scenarios
    prediction_scenarios_override.presence || fund_organization.default_prediction_scenarios
  end

  def thresholds
    thresholds_override.presence || fund_organization.default_thresholds
  end

  def effective_spend
    actual_spend || planned_spend || 0
  end

  def is_settled?
    total_returned >= cash_cap
  end

  def actual_spend_in_range?
    return false if actual_spend.blank?
    actual_spend >= min_allowed_spend && (max_allowed_spend.nil? || actual_spend <= max_allowed_spend)
  end

  def actual_spend_out_of_range?
    return false if actual_spend.blank?
    !actual_spend_in_range?
  end

  def payment_for_month(months_after)
    cohort_payments.find_by(months_after: months_after)
  end

  def set_actual_spend!(amount)
    self.actual_spend = amount

    if actual_spend_in_range?
      complete!
    else
      flag_for_review!
    end
  end

  private

  def set_defaults
    self.total_returned ||= 0
    self.min_allowed_spend ||= 0
  end

  def generate_investment_proposal
    # Calculate share percentage and cash cap based on planned_spend
    self.share_percentage = fund_organization.default_share_percentage
    self.cash_cap = planned_spend * share_percentage / 100.0 * 3.0 # Example: 3x return

    # Set allowed spend ranges
    self.min_allowed_spend = 0
    if fund_organization.max_invest_per_cohort
      self.max_allowed_spend = fund_organization.max_invest_per_cohort / share_percentage * 100.0
    end

    # Transition to pending_approval
    self.status = 'pending_approval'
    save!
  end

  def set_approved_at
    self.approved_at = Time.current
  end

  def set_completed_at
    self.completed_at = Time.current
  end

  def set_settled_at
    self.settled_at = Time.current
  end

  def set_terminated_at
    self.terminated_at = Time.current
  end

  def recalculate_cohort_payments
    RecalculateCohortPaymentsJob.perform_async(id)
  end
end
