import { useQuery } from '@tanstack/react-query'
import { cohortsApi } from '../lib/api'
import { useAuth } from '../contexts/AuthContext'
import Card from '../components/Card'
import StatusBadge from '../components/StatusBadge'
import { Link } from 'react-router-dom'

export default function CohortList() {
  const { user } = useAuth()
  const organizationId = user?.organization_id || 1

  const { data: cohorts = [], isLoading } = useQuery({
    queryKey: ['cohorts', organizationId],
    queryFn: () => cohortsApi.list(organizationId).then((res) => res.data),
    enabled: !!user,
  })

  if (isLoading) {
    return <div>Loading cohorts...</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">Cohorts</h1>
      </div>

      <Card>
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
                  Actual Spend
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cash Cap
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
              {cohorts.map((cohort) => (
                <tr key={cohort.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {new Date(cohort.cohort_start_date).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge status={cohort.status} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${cohort.planned_spend.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {cohort.actual_spend ? `$${cohort.actual_spend.toLocaleString()}` : '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {cohort.effective_cash_cap || cohort.cash_cap ? `$${(cohort.effective_cash_cap || cohort.cash_cap || 0).toLocaleString()}` : '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${cohort.total_returned.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-full bg-gray-200 rounded-full h-2.5 mr-2" style={{ width: '100px' }}>
                        <div
                          className="bg-primary-600 h-2.5 rounded-full"
                          style={{ width: `${Math.min(Number(cohort.progress_percentage || 0), 100)}%` }}
                        ></div>
                      </div>
                      <span className="text-sm text-gray-900">{Number(cohort.progress_percentage || 0).toFixed(1)}%</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <Link
                      to={`/cohorts/${cohort.id}`}
                      className="text-primary-600 hover:text-primary-900 font-medium"
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
