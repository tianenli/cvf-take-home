import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { transactionUploadsApi } from '../lib/api'
import { useAuth } from '../contexts/AuthContext'
import Card from '../components/Card'
import StatusBadge from '../components/StatusBadge'
import { formatCurrency } from '../utils/formatters'

export default function TransactionUpload() {
  const { user } = useAuth()
  const organizationId = user?.organization_id || 1
  const queryClient = useQueryClient()

  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isDragging, setIsDragging] = useState(false)
  const [showDetails, setShowDetails] = useState<number | null>(null)

  // Fetch transaction uploads
  const { data: uploads = [], isLoading } = useQuery({
    queryKey: ['transaction_uploads', organizationId],
    queryFn: () => transactionUploadsApi.list(organizationId).then((res) => res.data),
    enabled: !!user,
    refetchInterval: 5000, // Refetch every 5 seconds to update processing status
  })

  // Upload mutation
  const uploadMutation = useMutation({
    mutationFn: (file: File) => transactionUploadsApi.create(organizationId, file),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['transaction_uploads'] })
      setSelectedFile(null)
    },
  })

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setSelectedFile(file)
    }
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = () => {
    setIsDragging(false)
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)

    const file = e.dataTransfer.files[0]
    if (file && file.name.endsWith('.csv')) {
      setSelectedFile(file)
    }
  }

  const handleUpload = () => {
    if (selectedFile) {
      uploadMutation.mutate(selectedFile)
    }
  }

  const formatDate = (dateString: string | null) => {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleString()
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'processed':
        return 'text-green-600 bg-green-50'
      case 'processing':
        return 'text-blue-600 bg-blue-50'
      case 'errored':
        return 'text-red-600 bg-red-50'
      case 'submitted':
        return 'text-yellow-600 bg-yellow-50'
      default:
        return 'text-gray-600 bg-gray-50'
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Transaction Management</h1>
        <p className="mt-2 text-gray-600">
          Upload and manage customer payment transactions
        </p>
      </div>

      {/* Upload Form */}
      <Card title="Upload Transactions">
        <div className="space-y-4">
          <p className="text-sm text-gray-600">
            Upload a CSV file containing your customer payment transactions. The file should include the following columns:
          </p>
          <ul className="list-disc list-inside text-sm text-gray-600 space-y-1">
            <li><strong>customer_id:</strong> Unique identifier for the customer</li>
            <li><strong>payment_date:</strong> Date of the transaction (YYYY-MM-DD)</li>
            <li><strong>amount:</strong> Transaction amount</li>
            <li><strong>reference_id:</strong> (Optional) Your internal transaction ID</li>
          </ul>

          {/* Drag and Drop Area */}
          <div
            className={`mt-4 border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
              isDragging
                ? 'border-primary-500 bg-primary-50'
                : 'border-gray-300 hover:border-gray-400'
            }`}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
          >
            {selectedFile ? (
              <div className="space-y-2">
                <svg
                  className="mx-auto h-12 w-12 text-green-500"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
                <p className="text-sm font-medium text-gray-900">{selectedFile.name}</p>
                <p className="text-xs text-gray-500">
                  {(selectedFile.size / 1024).toFixed(2)} KB
                </p>
                <button
                  onClick={() => setSelectedFile(null)}
                  className="text-sm text-primary-600 hover:text-primary-700"
                >
                  Remove file
                </button>
              </div>
            ) : (
              <div className="space-y-2">
                <svg
                  className="mx-auto h-12 w-12 text-gray-400"
                  stroke="currentColor"
                  fill="none"
                  viewBox="0 0 48 48"
                  aria-hidden="true"
                >
                  <path
                    d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                    strokeWidth={2}
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
                <div className="flex text-sm text-gray-600">
                  <label className="relative cursor-pointer rounded-md font-medium text-primary-600 hover:text-primary-500">
                    <span>Upload a file</span>
                    <input
                      type="file"
                      accept=".csv"
                      onChange={handleFileSelect}
                      className="sr-only"
                    />
                  </label>
                  <p className="pl-1">or drag and drop</p>
                </div>
                <p className="text-xs text-gray-500">CSV files only</p>
              </div>
            )}
          </div>

          <button
            onClick={handleUpload}
            disabled={!selectedFile || uploadMutation.isPending}
            className="w-full px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
          >
            {uploadMutation.isPending ? 'Uploading...' : 'Upload Transactions'}
          </button>

          {uploadMutation.isError && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-md">
              <p className="text-sm text-red-800">
                Upload failed. Please check your file and try again.
              </p>
            </div>
          )}
        </div>
      </Card>

      {/* Upload History */}
      <Card title="Upload History">
        {isLoading ? (
          <div className="text-center py-8 text-gray-500">Loading uploads...</div>
        ) : uploads.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            No uploads yet. Upload your first CSV file above.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead>
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    File
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Rows
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Processed
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Failed
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Uploaded At
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {uploads.map((upload) => (
                  <>
                    <tr key={upload.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {upload.csv_file_name || 'Unknown'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span
                          className={`px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(
                            upload.status
                          )}`}
                        >
                          {upload.status.toUpperCase()}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {upload.total_rows ?? '-'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {upload.processed_rows ?? '-'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        {upload.failed_rows ? (
                          <span className="text-red-600 font-medium">{upload.failed_rows}</span>
                        ) : (
                          '-'
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatDate(upload.created_at)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <button
                          onClick={() =>
                            setShowDetails(showDetails === upload.id ? null : upload.id)
                          }
                          className="text-primary-600 hover:text-primary-900 font-medium"
                        >
                          {showDetails === upload.id ? 'Hide' : 'Details'}
                        </button>
                      </td>
                    </tr>
                    {showDetails === upload.id && (
                      <tr>
                        <td colSpan={7} className="px-6 py-4 bg-gray-50">
                          <div className="space-y-3">
                            <div className="grid grid-cols-2 gap-4 text-sm">
                              <div>
                                <span className="font-medium text-gray-700">Processing Started:</span>
                                <span className="ml-2 text-gray-600">
                                  {formatDate(upload.processing_started_at)}
                                </span>
                              </div>
                              <div>
                                <span className="font-medium text-gray-700">Processing Completed:</span>
                                <span className="ml-2 text-gray-600">
                                  {formatDate(upload.processing_completed_at)}
                                </span>
                              </div>
                            </div>
                            {upload.error_message && (
                              <div className="mt-3">
                                <span className="font-medium text-red-700">Error Summary:</span>
                                <p className="mt-1 text-sm text-red-800">{upload.error_message}</p>
                              </div>
                            )}
                            {upload.error_details && upload.error_details.length > 0 && (
                              <div className="mt-3">
                                <span className="font-medium text-red-700">Failed Rows:</span>
                                <div className="mt-2 max-h-60 overflow-y-auto">
                                  <table className="min-w-full text-xs border border-red-200">
                                    <thead className="bg-red-50 sticky top-0">
                                      <tr>
                                        <th className="px-3 py-2 text-left text-red-900 font-semibold border-b border-red-200">
                                          Row #
                                        </th>
                                        <th className="px-3 py-2 text-left text-red-900 font-semibold border-b border-red-200">
                                          Reference ID
                                        </th>
                                        <th className="px-3 py-2 text-left text-red-900 font-semibold border-b border-red-200">
                                          Customer ID
                                        </th>
                                        <th className="px-3 py-2 text-left text-red-900 font-semibold border-b border-red-200">
                                          Error
                                        </th>
                                      </tr>
                                    </thead>
                                    <tbody className="bg-white">
                                      {upload.error_details.map((error, idx) => (
                                        <tr key={idx} className="border-b border-red-100">
                                          <td className="px-3 py-2 text-red-900 font-mono">
                                            {error.row}
                                          </td>
                                          <td className="px-3 py-2 text-red-800 font-mono">
                                            {error.reference_id || '-'}
                                          </td>
                                          <td className="px-3 py-2 text-red-800 font-mono">
                                            {error.customer_id || '-'}
                                          </td>
                                          <td className="px-3 py-2 text-red-800">
                                            {error.error}
                                          </td>
                                        </tr>
                                      ))}
                                    </tbody>
                                  </table>
                                </div>
                              </div>
                            )}
                            {upload.csv_file_url && (
                              <div className="mt-3">
                                <a
                                  href={upload.csv_file_url}
                                  download
                                  className="inline-flex items-center text-sm text-primary-600 hover:text-primary-900"
                                >
                                  <svg
                                    className="w-4 h-4 mr-1"
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                  >
                                    <path
                                      strokeLinecap="round"
                                      strokeLinejoin="round"
                                      strokeWidth={2}
                                      d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                                    />
                                  </svg>
                                  Download CSV File
                                </a>
                              </div>
                            )}
                          </div>
                        </td>
                      </tr>
                    )}
                  </>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {/* CSV Format Example */}
      <Card title="CSV Format Example">
        <div className="bg-gray-50 p-4 rounded-md">
          <pre className="text-sm text-gray-800">
{`customer_id,payment_date,amount,reference_id
CUST001,2024-01-15,1250.00,TXN001
CUST002,2024-01-16,3500.50,TXN002
CUST001,2024-02-15,1300.00,TXN003`}
          </pre>
        </div>
      </Card>

      {/* Instructions */}
      <Card title="How it Works">
        <div className="space-y-3 text-sm text-gray-600">
          <div>
            <strong className="text-gray-900">1. Upload CSV File</strong>
            <p className="mt-1">Select or drag a CSV file with customer transactions. Required columns: customer_id, payment_date, amount.</p>
          </div>
          <div>
            <strong className="text-gray-900">2. Automatic Processing</strong>
            <p className="mt-1">The system processes your file in the background, matching customers to cohorts based on payment dates.</p>
          </div>
          <div>
            <strong className="text-gray-900">3. Transaction Creation</strong>
            <p className="mt-1">Valid transactions are created and automatically recalculate cohort payments and thresholds.</p>
          </div>
          <div className="mt-4 p-4 bg-blue-50 rounded-md">
            <strong className="text-blue-900">Note:</strong>
            <p className="mt-1 text-blue-800">
              Cohorts must exist for the payment months before uploading transactions. Create cohorts in the Spend Management section first.
            </p>
          </div>
        </div>
      </Card>
    </div>
  )
}
