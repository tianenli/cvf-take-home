import { useQuery } from '@tanstack/react-query'
import { organizationsApi, cohortsApi } from '../lib/api'
import { useAuth } from '../contexts/AuthContext'
import Card from '../components/Card'
import StatusBadge from '../components/StatusBadge'
import { Link } from 'react-router-dom'
import { formatCurrency, formatMonthYear } from '../utils/formatters'

export default function Dashboard() {
  const { user } = useAuth()
  const organizationId = user?.organization_id || 1

  const { data: organization } = useQuery({
    queryKey: ['organization', organizationId],
    queryFn: () => organizationsApi.get(organizationId).then((res) => res.data),
    enabled: !!user,
  })

  const { data: cohorts = [] } = useQuery({
    queryKey: ['cohorts', organizationId],
    queryFn: () => cohortsApi.list(organizationId).then((res) => res.data),
    enabled: !!user,
  })

  const stats = {
    totalCohorts: cohorts.length,
    activeCohorts: cohorts.filter((c) => ['approved', 'pending_review', 'completed'].includes(c.status)).length,
    totalInvested: cohorts.reduce((sum, c) => sum + c.planned_spend, 0),
    totalReturned: cohorts.reduce((sum, c) => sum + c.total_returned, 0),
  }

  const recentCohorts = cohorts.slice(0, 5)

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">
          Welcome, {organization?.name || 'Loading...'}
        </h1>
        <p className="mt-2 text-gray-600">
          Here's an overview of your CVF partnership
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <div className="space-y-2">
            <p className="text-sm font-medium text-gray-600">Total Cohorts</p>
            <p className="text-3xl font-bold text-gray-900">{stats.totalCohorts}</p>
          </div>
        </Card>

        <Card>
          <div className="space-y-2">
            <p className="text-sm font-medium text-gray-600">Active Cohorts</p>
            <p className="text-3xl font-bold text-green-600">{stats.activeCohorts}</p>
          </div>
        </Card>

        <Card>
          <div className="space-y-2">
            <p className="text-sm font-medium text-gray-600">Total Invested</p>
            <p className="text-3xl font-bold text-gray-900">
              {formatCurrency(stats.totalInvested)}
            </p>
          </div>
        </Card>

        <Card>
          <div className="space-y-2">
            <p className="text-sm font-medium text-gray-600">Total Returned</p>
            <p className="text-3xl font-bold text-primary-600">
              {formatCurrency(stats.totalReturned)}
            </p>
          </div>
        </Card>
      </div>

      <Card title="Recent Cohorts">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cohort Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Planned Spend
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Returned
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Progress
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {recentCohorts.map((cohort) => (
                <tr key={cohort.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {formatMonthYear(cohort.cohort_start_date)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge status={cohort.status} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {formatCurrency(cohort.planned_spend)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {formatCurrency(cohort.total_returned)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {Number(cohort.progress_percentage || 0).toFixed(1)}%
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <Link
                      to={`/cohorts/${cohort.id}`}
                      className="text-primary-600 hover:text-primary-900"
                    >
                      View Details
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  )
}
