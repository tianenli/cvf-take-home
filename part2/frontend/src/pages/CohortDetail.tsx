import { useParams } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { cohortsApi } from '../lib/api'
import Card from '../components/Card'
import StatusBadge from '../components/StatusBadge'

const ORGANIZATION_ID = 1

export default function CohortDetail() {
  const { id } = useParams<{ id: string }>()

  const { data: cohort, isLoading } = useQuery({
    queryKey: ['cohort', ORGANIZATION_ID, id],
    queryFn: () => cohortsApi.get(ORGANIZATION_ID, Number(id!)).then((res) => res.data),
    enabled: !!id,
  })

  if (isLoading) {
    return <div>Loading cohort details...</div>
  }

  if (!cohort) {
    return <div>Cohort not found</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">
            Cohort: {new Date(cohort.cohort_start_date).toLocaleDateString()}
          </h1>
          <p className="mt-2 text-gray-600">
            {cohort.organization_name} • {cohort.fund_name}
          </p>
        </div>
        <StatusBadge status={cohort.status} />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card title="Financial Overview">
          <div className="space-y-4">
            <div>
              <p className="text-sm text-gray-600">Committed Spend</p>
              <p className="text-2xl font-bold text-gray-900">${cohort.committed.toLocaleString()}</p>
            </div>
            {cohort.adjustment && (
              <div>
                <p className="text-sm text-gray-600">Adjustment</p>
                <p className="text-2xl font-bold text-gray-900">${cohort.adjustment.toLocaleString()}</p>
              </div>
            )}
            <div>
              <p className="text-sm text-gray-600">Actual Spend</p>
              <p className="text-2xl font-bold text-gray-900">${cohort.actual_spend.toLocaleString()}</p>
            </div>
          </div>
        </Card>

        <Card title="Returns">
          <div className="space-y-4">
            <div>
              <p className="text-sm text-gray-600">Total Returned</p>
              <p className="text-2xl font-bold text-primary-600">${cohort.total_returned.toLocaleString()}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Cash Cap</p>
              <p className="text-2xl font-bold text-gray-900">${cohort.cash_cap.toLocaleString()}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Progress</p>
              <div className="flex items-center">
                <div className="w-full bg-gray-200 rounded-full h-2.5 mr-2">
                  <div
                    className="bg-primary-600 h-2.5 rounded-full"
                    style={{ width: `${Math.min(cohort.progress_percentage, 100)}%` }}
                  ></div>
                </div>
                <span className="text-sm font-medium">{cohort.progress_percentage.toFixed(1)}%</span>
              </div>
            </div>
          </div>
        </Card>

        <Card title="Terms">
          <div className="space-y-4">
            <div>
              <p className="text-sm text-gray-600">Share Percentage</p>
              <p className="text-2xl font-bold text-gray-900">{cohort.share_percentage}%</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Status</p>
              <p className="text-lg font-medium">{cohort.status.toUpperCase()}</p>
            </div>
          </div>
        </Card>
      </div>

      <Card title="Monthly Payments">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Month
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Revenue
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  % of Spend
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Threshold Hit
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Share %
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Owed
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Paid
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Outstanding
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {cohort.cohort_payments.map((payment) => (
                <tr key={payment.id} className={payment.threshold_hit ? 'bg-red-50' : ''}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    M{payment.months_after}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge status={payment.status} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${payment.total_revenue.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {payment.payment_percent_of_spend.toFixed(2)}%
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    {payment.threshold_hit ? (
                      <span className="text-red-600 font-medium">Yes</span>
                    ) : (
                      <span className="text-green-600">No</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {payment.share_percentage}%
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${payment.total_owed.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${payment.total_paid.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    ${payment.outstanding_amount.toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {cohort.thresholds && cohort.thresholds.length > 0 && (
        <Card title="Threshold Configuration">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead>
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Payment Period Month
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Minimum Payment Percent
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {cohort.thresholds.map((threshold, index) => (
                  <tr key={index}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      M{threshold.payment_period_month}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {(threshold.minimum_payment_percent * 100).toFixed(1)}%
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  )
}
