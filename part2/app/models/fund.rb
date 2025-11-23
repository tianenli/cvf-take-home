class Fund < ApplicationRecord
  # Associations
  has_many :fund_organizations, dependent: :destroy
  has_many :organizations, through: :fund_organizations

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :start_date, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :active, -> { where('start_date <= ? AND (end_date IS NULL OR end_date >= ?)', Date.today, Date.today) }

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
