class OrganizationDetailSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :stats

  has_many :fund_organizations
  has_many :cohorts

  def stats
    {
      total_cohorts: object.cohorts.count,
      active_cohorts: object.cohorts.where(status: ['active', 'completed']).count,
      total_invested: object.cohorts.where.not(status: 'new').sum(:committed),
      total_returned: object.cohorts.sum(:total_returned)
    }
  end
end
