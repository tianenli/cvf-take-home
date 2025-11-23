class Threshold
  include StoreModel::Model

  attribute :payment_period_month, :integer
  attribute :minimum_payment_percent, :float

  validates :payment_period_month, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_payment_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
