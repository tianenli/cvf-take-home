import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { cohortsApi } from '../lib/api'
import { useAuth } from '../contexts/AuthContext'
import Card from '../components/Card'
import StatusBadge from '../components/StatusBadge'
import { formatCurrency, formatMonthYear } from '../utils/formatters'

export default function SpendManagement() {
  const { user } = useAuth()
  const organizationId = user?.organization_id || 1
  const queryClient = useQueryClient()

  // State for modals and forms
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [editingCohort, setEditingCohort] = useState<number | null>(null)
  const [approveConfirm, setApproveConfirm] = useState<number | null>(null)

  // Form data states
  const [createFormData, setCreateFormData] = useState({
    cohort_start_date: '',
    planned_spend: '',
  })
  const [editFormData, setEditFormData] = useState({
    planned_spend: '',
    actual_spend: '',
  })

  const { data: cohorts = [], isLoading } = useQuery({
    queryKey: ['cohorts', organizationId],
    queryFn: () => cohortsApi.list(organizationId).then((res) => res.data),
    enabled: !!user,
  })

  // Create cohort mutation
  const createMutation = useMutation({
    mutationFn: (data: { cohort_start_date: string; planned_spend: number }) =>
      cohortsApi.create(organizationId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cohorts'] })
      setShowCreateModal(false)
      setCreateFormData({ cohort_start_date: '', planned_spend: '' })
    },
  })

  // Update cohort mutation
  const updateMutation = useMutation({
    mutationFn: ({ cohortId, data }: { cohortId: number; data: any }) =>
      cohortsApi.update(organizationId, cohortId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cohorts'] })
      setEditingCohort(null)
      setEditFormData({ planned_spend: '', actual_spend: '' })
    },
  })

  // Submit cohort mutation
  const submitMutation = useMutation({
    mutationFn: (cohortId: number) => cohortsApi.submit(organizationId, cohortId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cohorts'] })
    },
  })

  // Approve cohort mutation
  const approveMutation = useMutation({
    mutationFn: (cohortId: number) => cohortsApi.approve(organizationId, cohortId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cohorts'] })
      setApproveConfirm(null)
    },
  })

  const handleCreateSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    createMutation.mutate({
      cohort_start_date: createFormData.cohort_start_date,
      planned_spend: parseFloat(createFormData.planned_spend),
    })
  }

  const handleEdit = (cohort: any) => {
    setEditingCohort(cohort.id)
    setEditFormData({
      planned_spend: cohort.planned_spend?.toString() || '',
      actual_spend: cohort.actual_spend?.toString() || '',
    })
  }

  const handleSave = (cohortId: number, cohort: any) => {
    if (cohort.status === 'new' || cohort.status === 'submitted') {
      // Update planned_spend
      updateMutation.mutate({
        cohortId,
        data: { planned_spend: parseFloat(editFormData.planned_spend) },
      })
    } else if (cohort.status === 'approved' || cohort.status === 'pending_review') {
      // Update actual_spend
      updateMutation.mutate({
        cohortId,
        data: { actual_spend: parseFloat(editFormData.actual_spend) },
      })
    }
  }

  const handleCancel = () => {
    setEditingCohort(null)
    setEditFormData({ planned_spend: '', actual_spend: '' })
  }

  const handleSubmit = (cohortId: number) => {
    if (confirm('Are you sure you want to submit this cohort for approval?')) {
      submitMutation.mutate(cohortId)
    }
  }

  const handleApprove = (cohortId: number) => {
    approveMutation.mutate(cohortId)
  }

  const getActionButtons = (cohort: any) => {
    if (editingCohort === cohort.id) {
      return (
        <div className="flex space-x-2">
          <button
            onClick={() => handleSave(cohort.id, cohort)}
            className="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700 disabled:bg-gray-300"
            disabled={updateMutation.isPending}
          >
            Save
          </button>
          <button
            onClick={handleCancel}
            className="px-3 py-1 text-sm bg-gray-300 text-gray-700 rounded hover:bg-gray-400"
          >
            Cancel
          </button>
        </div>
      )
    }

    switch (cohort.status) {
      case 'new':
        return (
          <div className="flex space-x-2">
            <button
              onClick={() => handleEdit(cohort)}
              className="px-3 py-1 text-sm bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              Edit Plan
            </button>
            <button
              onClick={() => handleSubmit(cohort.id)}
              className="px-3 py-1 text-sm bg-primary-600 text-white rounded hover:bg-primary-700 disabled:bg-gray-300"
              disabled={submitMutation.isPending}
            >
              Submit
            </button>
          </div>
        )

      case 'pending_approval':
        return (
          <button
            onClick={() => setApproveConfirm(cohort.id)}
            className="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700"
          >
            Approve
          </button>
        )

      case 'approved':
      case 'pending_review':
        return (
          <button
            onClick={() => handleEdit(cohort)}
            className="px-3 py-1 text-sm bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Update Actual
          </button>
        )

      case 'completed':
      case 'settled':
      case 'terminated':
        return (
          <span className="text-sm text-gray-500">No actions</span>
        )

      default:
        return null
    }
  }

  if (isLoading) {
    return <div>Loading...</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Spend Management</h1>
          <p className="mt-2 text-gray-600">
            Manage planned spend for future cohorts and report actual spend for active cohorts
          </p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 font-medium"
        >
          Create New Cohort
        </button>
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
                  Share %
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cash Cap
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
                <tr key={cohort.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {formatMonthYear(cohort.cohort_start_date)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge status={cohort.status} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {editingCohort === cohort.id && (cohort.status === 'new' || cohort.status === 'submitted') ? (
                      <input
                        type="number"
                        value={editFormData.planned_spend}
                        onChange={(e) => setEditFormData({ ...editFormData, planned_spend: e.target.value })}
                        className="border rounded px-2 py-1 w-32"
                        step="0.01"
                      />
                    ) : (
                      formatCurrency(cohort.planned_spend)
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {editingCohort === cohort.id && (cohort.status === 'approved' || cohort.status === 'pending_review') ? (
                      <input
                        type="number"
                        value={editFormData.actual_spend}
                        onChange={(e) => setEditFormData({ ...editFormData, actual_spend: e.target.value })}
                        className="border rounded px-2 py-1 w-32"
                        step="0.01"
                      />
                    ) : (
                      formatCurrency(cohort.actual_spend)
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {cohort.share_percentage !== null ? `${cohort.share_percentage}%` : '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {formatCurrency(cohort.effective_cash_cap || cohort.cash_cap)}
                    {cohort.adjusted_cash_cap && (
                      <span className="text-xs text-gray-500 block">
                        (adjusted)
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {Number(cohort.progress_percentage || 0).toFixed(1)}%
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    {getActionButtons(cohort)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Create Cohort Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <h2 className="text-2xl font-bold mb-4">Create New Cohort</h2>
            <form onSubmit={handleCreateSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Cohort Month
                </label>
                <input
                  type="month"
                  value={createFormData.cohort_start_date.substring(0, 7)}
                  onChange={(e) => setCreateFormData({ ...createFormData, cohort_start_date: e.target.value + '-01' })}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Planned Spend ($)
                </label>
                <input
                  type="number"
                  value={createFormData.planned_spend}
                  onChange={(e) => setCreateFormData({ ...createFormData, planned_spend: e.target.value })}
                  className="w-full border rounded px-3 py-2"
                  step="0.01"
                  required
                />
              </div>
              <div className="flex space-x-3 mt-6">
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-primary-600 text-white rounded hover:bg-primary-700 disabled:bg-gray-300"
                  disabled={createMutation.isPending}
                >
                  {createMutation.isPending ? 'Creating...' : 'Create Cohort'}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowCreateModal(false)
                    setCreateFormData({ cohort_start_date: '', planned_spend: '' })
                  }}
                  className="flex-1 px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Approve Confirmation Modal */}
      {approveConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <h2 className="text-2xl font-bold mb-4">Approve Investment Proposal</h2>
            {(() => {
              const cohort = cohorts.find(c => c.id === approveConfirm)
              return cohort ? (
                <div className="space-y-3 mb-6">
                  <p className="text-gray-700">
                    Review the investment proposal for cohort starting <strong>{formatMonthYear(cohort.cohort_start_date)}</strong>:
                  </p>
                  <div className="bg-gray-50 p-4 rounded space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-600">Planned Spend:</span>
                      <span className="font-medium">{formatCurrency(cohort.planned_spend)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Share Percentage:</span>
                      <span className="font-medium">{cohort.share_percentage}%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Cash Cap:</span>
                      <span className="font-medium">{formatCurrency(cohort.cash_cap)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Min Allowed Spend:</span>
                      <span className="font-medium">{formatCurrency(cohort.min_allowed_spend)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Max Allowed Spend:</span>
                      <span className="font-medium">{formatCurrency(cohort.max_allowed_spend)}</span>
                    </div>
                  </div>
                  <p className="text-sm text-gray-600 mt-4">
                    By approving, you agree to these investment terms and the cohort will become active.
                  </p>
                </div>
              ) : null
            })()}
            <div className="flex space-x-3">
              <button
                onClick={() => handleApprove(approveConfirm)}
                className="flex-1 px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:bg-gray-300"
                disabled={approveMutation.isPending}
              >
                {approveMutation.isPending ? 'Approving...' : 'Approve'}
              </button>
              <button
                onClick={() => setApproveConfirm(null)}
                className="flex-1 px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      <Card title="How it works">
        <div className="space-y-3 text-sm text-gray-600">
          <div>
            <strong className="text-gray-900">1. Create & Submit</strong>
            <p className="mt-1">Create a new cohort with planned spend for an upcoming month, then submit it for approval.</p>
          </div>
          <div>
            <strong className="text-gray-900">2. Review & Approve</strong>
            <p className="mt-1">Review the investment proposal including share percentage and cash cap, then approve to activate the cohort.</p>
          </div>
          <div>
            <strong className="text-gray-900">3. Report Actual Spend</strong>
            <p className="mt-1">Once the month is over, report the actual spend amount. The cash cap will be adjusted proportionally if actual differs from planned.</p>
          </div>
          <div className="mt-4 p-4 bg-blue-50 rounded-md">
            <strong className="text-blue-900">Note:</strong>
            <p className="mt-1 text-blue-800">
              When you update spend amounts, cohort payments will be automatically recalculated in the background.
              The adjusted cash cap ensures return multiples remain consistent with original terms.
            </p>
          </div>
        </div>
      </Card>
    </div>
  )
}
