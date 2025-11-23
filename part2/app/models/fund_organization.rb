class FundOrganization < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :fund
  has_many :cohorts, dependent: :restrict_with_error

  # StoreModel for JSON columns
  attribute :default_prediction_scenarios, PredictionScenario.to_array_type
  attribute :default_thresholds, Threshold.to_array_type

  # Validations
  validates :organization_id, uniqueness: { scope: :fund_id }
  validates :default_share_percentage, presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :max_invest_per_cohort, numericality: { greater_than: 0 }, allow_nil: true
  validates :max_total_invest, numericality: { greater_than: 0 }, allow_nil: true
  validate :first_cohort_before_last_cohort

  # Callbacks
  before_validation :set_defaults, on: :create

  def total_invested
    cohorts.where.not(status: 'new').sum(:committed)
  end

  def remaining_capacity
    return nil if max_total_invest.nil?
    max_total_invest - total_invested
  end

  def can_invest?(amount)
    return false if max_invest_per_cohort && amount > max_invest_per_cohort
    return false if max_total_invest && (total_invested + amount) > max_total_invest
    true
  end

  private

  def set_defaults
    self.default_share_percentage ||= 20.0

    if default_prediction_scenarios.blank?
      self.default_prediction_scenarios = [
        PredictionScenario.new(scenario: 'WORST', m0: 0.15, churn: 0.10),
        PredictionScenario.new(scenario: 'AVERAGE', m0: 0.25, churn: 0.05),
        PredictionScenario.new(scenario: 'BEST', m0: 0.35, churn: 0.02)
      ]
    end

    if default_thresholds.blank?
      self.default_thresholds = [
        Threshold.new(payment_period_month: 0, minimum_payment_percent: 0.15),
        Threshold.new(payment_period_month: 1, minimum_payment_percent: 0.20),
        Threshold.new(payment_period_month: 2, minimum_payment_percent: 0.18),
        Threshold.new(payment_period_month: 3, minimum_payment_percent: 0.16)
      ]
    end
  end

  def first_cohort_before_last_cohort
    return if first_cohort_date.blank? || last_cohort_date.blank?

    if last_cohort_date < first_cohort_date
      errors.add(:last_cohort_date, "must be after first cohort date")
    end
  end
end
