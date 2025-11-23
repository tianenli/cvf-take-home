import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { cohortsApi } from '../lib/api'
import { useAuth } from '../contexts/AuthContext'
import Card from '../components/Card'
import StatusBadge from '../components/StatusBadge'

export default function SpendManagement() {
  const { user } = useAuth()
  const organizationId = user?.organization_id || 1
  const queryClient = useQueryClient()
  const [editingCohort, setEditingCohort] = useState<number | null>(null)
  const [formData, setFormData] = useState({ committed: '', adjustment: '' })

  const { data: cohorts = [], isLoading } = useQuery({
    queryKey: ['cohorts', organizationId],
    queryFn: () => cohortsApi.list(organizationId).then((res) => res.data),
    enabled: !!user,
  })

  const updateMutation = useMutation({
    mutationFn: ({ cohortId, data }: { cohortId: number; data: any }) =>
      cohortsApi.update(organizationId, cohortId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cohorts'] })
      setEditingCohort(null)
      setFormData({ committed: '', adjustment: '' })
    },
  })

  const handleEdit = (cohort: any) => {
    setEditingCohort(cohort.id)
    setFormData({
      committed: cohort.committed.toString(),
      adjustment: cohort.adjustment?.toString() || '',
    })
  }

  const handleSave = (cohortId: number) => {
    const data: any = {
      committed: parseFloat(formData.committed),
    }
    if (formData.adjustment) {
      data.adjustment = parseFloat(formData.adjustment)
    }
    updateMutation.mutate({ cohortId, data })
  }

  const handleCancel = () => {
    setEditingCohort(null)
    setFormData({ committed: '', adjustment: '' })
  }

  if (isLoading) {
    return <div>Loading...</div>
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Spend Management</h1>
        <p className="mt-2 text-gray-600">
          Update your committed spend and adjustments for each cohort
        </p>
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
                  Committed
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Adjustment
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actual Spend
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {cohorts.map((cohort) => (
                <tr key={cohort.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {new Date(cohort.cohort_start_date).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge status={cohort.status} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {editingCohort === cohort.id ? (
                      <input
                        type="number"
                        value={formData.committed}
                        onChange={(e) => setFormData({ ...formData, committed: e.target.value })}
                        className="border rounded px-2 py-1 w-32"
                        step="0.01"
                      />
                    ) : (
                      `$${cohort.committed.toLocaleString()}`
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {editingCohort === cohort.id ? (
                      <input
                        type="number"
                        value={formData.adjustment}
                        onChange={(e) => setFormData({ ...formData, adjustment: e.target.value })}
                        className="border rounded px-2 py-1 w-32"
                        step="0.01"
                        placeholder="Optional"
                      />
                    ) : cohort.adjustment ? (
                      `$${cohort.adjustment.toLocaleString()}`
                    ) : (
                      '-'
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${cohort.actual_spend.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    {editingCohort === cohort.id ? (
                      <div className="flex space-x-2">
                        <button
                          onClick={() => handleSave(cohort.id)}
                          className="text-green-600 hover:text-green-900 font-medium"
                          disabled={updateMutation.isPending}
                        >
                          Save
                        </button>
                        <button
                          onClick={handleCancel}
                          className="text-gray-600 hover:text-gray-900 font-medium"
                        >
                          Cancel
                        </button>
                      </div>
                    ) : (
                      <button
                        onClick={() => handleEdit(cohort)}
                        className="text-primary-600 hover:text-primary-900 font-medium"
                      >
                        Edit
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      <Card title="Instructions">
        <div className="space-y-2 text-sm text-gray-600">
          <p>
            <strong>Committed:</strong> The amount of money you plan to spend on S&M for this cohort
          </p>
          <p>
            <strong>Adjustment:</strong> The actual amount spent (if different from committed). Leave blank to use committed amount.
          </p>
          <p>
            <strong>Actual Spend:</strong> This is calculated as adjustment (if provided) or committed amount
          </p>
          <p className="mt-4 p-4 bg-blue-50 rounded-md">
            <strong>Note:</strong> When you update spend amounts, the cohort payments will be automatically recalculated in the background.
          </p>
        </div>
      </Card>
    </div>
  )
}
