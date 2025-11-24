interface StatusBadgeProps {
  status: string
}

export default function StatusBadge({ status }: StatusBadgeProps) {
  const colors: Record<string, string> = {
    new: 'bg-gray-100 text-gray-800',
    submitted: 'bg-blue-100 text-blue-800',
    pending_approval: 'bg-yellow-100 text-yellow-800',
    approved: 'bg-green-100 text-green-800',
    pending_review: 'bg-orange-100 text-orange-800',
    completed: 'bg-blue-100 text-blue-800',
    settled: 'bg-purple-100 text-purple-800',
    terminated: 'bg-red-100 text-red-800',
    computing: 'bg-yellow-100 text-yellow-800',
    finalized: 'bg-blue-100 text-blue-800',
  }

  const labels: Record<string, string> = {
    new: 'NEW',
    submitted: 'SUBMITTED',
    pending_approval: 'PENDING APPROVAL',
    approved: 'APPROVED',
    pending_review: 'PENDING REVIEW',
    completed: 'COMPLETED',
    settled: 'SETTLED',
    terminated: 'TERMINATED',
    computing: 'COMPUTING',
    finalized: 'FINALIZED',
  }

  return (
    <span
      className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
        colors[status] || 'bg-gray-100 text-gray-800'
      }`}
    >
      {labels[status] || status.toUpperCase()}
    </span>
  )
}
