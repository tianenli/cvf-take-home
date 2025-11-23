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
  validates :share_percentage, presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :cash_cap, presence: true, numericality: { greater_than: 0 }
  validates :committed, numericality: { greater_than_or_equal_to: 0 }
  validates :adjustment, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_returned, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_defaults, on: :create
  after_save :recalculate_cohort_payments, if: :saved_change_to_adjustment?

  # Scopes
  scope :active_cohorts, -> { where(status: ['active', 'completed']) }
  scope :for_date, ->(date) { where(cohort_start_date: date) }

  # AASM State Machine
  aasm column: :status do
    state :new, initial: true
    state :active
    state :completed
    state :settled
    state :terminated

    event :approve do
      transitions from: :new, to: :active, after: :set_approved_at
    end

    event :complete do
      transitions from: :active, to: :completed, after: :set_completed_at
    end

    event :settle do
      transitions from: [:active, :completed], to: :settled, after: :set_settled_at
    end

    event :terminate do
      transitions from: [:active, :completed], to: :terminated, after: :set_terminated_at
    end
  end

  def prediction_scenarios
    prediction_scenarios_override.presence || fund_organization.default_prediction_scenarios
  end

  def thresholds
    thresholds_override.presence || fund_organization.default_thresholds
  end

  def actual_spend
    adjustment || committed
  end

  def is_settled?
    total_returned >= cash_cap
  end

  def payment_for_month(months_after)
    cohort_payments.find_by(months_after: months_after)
  end

  private

  def set_defaults
    self.share_percentage ||= fund_organization.default_share_percentage
    self.committed ||= 0
    self.total_returned ||= 0
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
