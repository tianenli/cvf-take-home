import Card from '../components/Card'

export default function TransactionUpload() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Transaction Management</h1>
        <p className="mt-2 text-gray-600">
          Upload and manage customer payment transactions
        </p>
      </div>

      <Card title="Upload Transactions">
        <div className="space-y-4">
          <p className="text-sm text-gray-600">
            Upload a CSV file containing your customer payment transactions. The file should include the following columns:
          </p>
          <ul className="list-disc list-inside text-sm text-gray-600 space-y-1">
            <li><strong>customer_id:</strong> Unique identifier for the customer</li>
            <li><strong>payment_date:</strong> Date of the transaction (YYYY-MM-DD)</li>
            <li><strong>amount:</strong> Transaction amount</li>
            <li><strong>reference_id:</strong> Your internal transaction ID</li>
          </ul>

          <div className="mt-4">
            <label className="block">
              <span className="sr-only">Choose file</span>
              <input
                type="file"
                accept=".csv"
                className="block w-full text-sm text-gray-500
                  file:mr-4 file:py-2 file:px-4
                  file:rounded-md file:border-0
                  file:text-sm file:font-semibold
                  file:bg-primary-50 file:text-primary-700
                  hover:file:bg-primary-100"
              />
            </label>
          </div>

          <button
            className="mt-4 px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 transition-colors"
          >
            Upload Transactions
          </button>
        </div>
      </Card>

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

      <Card title="Instructions">
        <div className="space-y-2 text-sm text-gray-600">
          <p>
            1. Prepare your CSV file with the columns listed above
          </p>
          <p>
            2. Upload the file using the form above
          </p>
          <p>
            3. The system will process the transactions and:
          </p>
          <ul className="list-disc list-inside ml-4 space-y-1">
            <li>Create or match customers to their cohorts</li>
            <li>Record the transactions</li>
            <li>Automatically recalculate cohort payments</li>
            <li>Update threshold checks</li>
            <li>Recalculate amounts owed to CVF</li>
          </ul>
          <p className="mt-4 p-4 bg-yellow-50 rounded-md">
            <strong>Note:</strong> This is a demo interface. In production, you would implement actual CSV parsing and API calls to create transactions.
          </p>
        </div>
      </Card>
    </div>
  )
}
