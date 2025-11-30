# Transaction Upload CSV Format

## Overview

The transaction upload feature allows organizations to bulk upload customer transactions via CSV files. Files are uploaded to S3 (LocalStack in development) and processed asynchronously via Sidekiq.

## CSV Format

The CSV file must contain the following columns:

| Column | Required | Description | Example |
|--------|----------|-------------|---------|
| customer_id | Yes | Unique identifier for the customer | CUST-12345 |
| payment_date | Yes | Date of the transaction (YYYY-MM-DD) | 2024-01-15 |
| amount | Yes | Transaction amount (decimal) | 99.99 |
| reference_id | No | Unique transaction identifier (auto-generated if not provided) | TXN-ABC123 |

## Sample CSV

```csv
customer_id,payment_date,amount,reference_id
CUST-001,2024-01-15,150.00,TXN-001
CUST-002,2024-01-20,250.50,TXN-002
CUST-001,2024-02-10,100.00,TXN-003
```

## Processing Logic

1. **Cohort Assignment**: Transactions are assigned to cohorts based on the `payment_date` (month). The cohort must already exist for that month.

2. **Customer Creation**: If a customer with the given `customer_id` doesn't exist in the cohort, they will be automatically created.

3. **Transaction Deduplication**: Transactions with duplicate `reference_id` values for the same organization will be rejected.

4. **Error Handling**:
   - If any row fails to process, the upload status will be marked as `errored`
   - Detailed error messages are stored in the `error_message` field
   - Successfully processed rows are still saved

## Upload Statuses

- **submitted**: Initial state after upload
- **processing**: CSV is being parsed and transactions are being created
- **processed**: All transactions successfully created
- **errored**: One or more transactions failed to process

## API Endpoints

### Create Upload
```
POST /api/v1/organizations/:organization_id/transaction_uploads
Content-Type: multipart/form-data

{
  "csv_file": <file>
}
```

### List Uploads
```
GET /api/v1/organizations/:organization_id/transaction_uploads
```

### Get Upload Details
```
GET /api/v1/organizations/:organization_id/transaction_uploads/:id
```

## Prerequisites

Before uploading transactions:

1. **Cohorts must exist**: Create cohorts for the months that transactions will be assigned to
2. **Fund organization**: The organization must have at least one active fund organization

## Error Examples

Common errors:

- `No cohort found for date 2024-01-01. Please create cohort first.`
- `Missing customer_id` (row missing required field)
- `Missing payment_date` (row missing required field)
- `Missing amount` (row missing required field)
- Duplicate `reference_id` (transaction already exists)
