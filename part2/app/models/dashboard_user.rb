class DashboardUser < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Callbacks
  before_create :set_jti

  # Associations
  belongs_to :organization

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # Delegations
  delegate :fund_organizations, to: :organization
  delegate :funds, to: :organization
  delegate :cohorts, to: :organization

  # Check if user has access to a specific fund
  def has_access_to_fund?(fund_id)
    funds.exists?(id: fund_id)
  end

  # Check if user has access to a specific cohort
  def has_access_to_cohort?(cohort_id)
    cohorts.exists?(id: cohort_id)
  end

  private

  def set_jti
    self.jti = SecureRandom.uuid
  end
end
