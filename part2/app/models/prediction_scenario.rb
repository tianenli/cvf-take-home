class PredictionScenario
  include StoreModel::Model

  attribute :scenario, :string
  attribute :m0, :float
  attribute :churn, :float

  validates :scenario, presence: true, inclusion: { in: %w[WORST AVERAGE BEST] }
  validates :m0, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :churn, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
