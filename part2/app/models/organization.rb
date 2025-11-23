class Organization < ApplicationRecord
  # Associations
  has_many :fund_organizations, dependent: :destroy
  has_many :funds, through: :fund_organizations
  has_many :txns, dependent: :restrict_with_error
  has_many :customers, through: :cohorts
  has_many :dashboard_users, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true

  # Scopes
  scope :active, -> { joins(:fund_organizations).distinct }

  def cohorts
    Cohort.joins(:fund_organization).where(fund_organizations: { organization_id: id })
  end
end
