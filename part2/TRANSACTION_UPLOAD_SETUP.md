# Transaction Upload Backend Setup - Summary

This document summarizes the complete backend setup for transaction CSV upload management with S3 storage and async processing.

## Components Added

### 1. LocalStack for Local S3 (docker-compose.yml)

- Added LocalStack service for mock S3 in development
- Configured S3 endpoint at `http://localstack:4566`
- Added health checks for LocalStack service
- Added environment variables for S3 configuration to all Rails services (web, worker, scheduler)

**Environment Variables:**
- `AWS_ACCESS_KEY_ID=test`
- `AWS_SECRET_ACCESS_KEY=test`
- `AWS_REGION=us-east-1`
- `S3_BUCKET=cvf-transactions`
- `S3_ENDPOINT=http://localstack:4566`

### 2. ActiveStorage Configuration

**Files Created/Modified:**
- `config/storage.yml` - S3 storage configuration
- `config/environments/development.rb` - Set active_storage service to :amazon
- `config/initializers/active_storage.rb` - Auto-create S3 bucket on Rails startup
- `Gemfile` - Added `aws-sdk-s3` gem

**Migrations:**
- `db/migrate/20251129000001_create_active_storage_tables.rb` - ActiveStorage tables

### 3. TransactionUpload Model

**Files Created:**
- `app/models/transaction_upload.rb` - Model with AASM state machine
- `db/migrate/20251129000002_create_transaction_uploads.rb` - Database migration

**Model Features:**
- AASM states: `submitted`, `processing`, `processed`, `errored`
- Attached CSV file via ActiveStorage (`has_one_attached :csv_file`)
- Automatic job enqueuing on creation
- Validations for CSV file presence and content type
- Tracking fields: total_rows, processed_rows, failed_rows, error_message
- Timestamps: processing_started_at, processing_completed_at

**Associations:**
- `belongs_to :organization`
- Added `has_many :transaction_uploads` to Organization model

### 4. Sidekiq Job for CSV Processing

**File Created:**
- `app/jobs/process_transaction_upload_job.rb`

**Job Features:**
- Downloads CSV from S3
- Parses CSV with headers
- Validates required fields (customer_id, payment_date, amount)
- Finds or creates customers in appropriate cohorts
- Creates transaction records
- Handles errors per row
- Updates upload status and statistics
- Transitions upload state based on success/failure

**CSV Processing Logic:**
1. Cohort is determined by payment_date (beginning of month)
2. Customers are found or created by reference_id within cohort
3. Transactions are created with deduplication by reference_id
4. Errors are collected and stored in error_message field

### 5. API Controller

**File Created:**
- `app/controllers/api/v1/transaction_uploads_controller.rb`

**Endpoints:**
- `POST /api/v1/organizations/:organization_id/transaction_uploads` - Create upload
- `GET /api/v1/organizations/:organization_id/transaction_uploads` - List uploads
- `GET /api/v1/organizations/:organization_id/transaction_uploads/:id` - Get upload details

**Authorization:**
- Uses existing BaseController authentication
- Organization-scoped access control via `authorize_organization!`

### 6. Serializer

**File Created:**
- `app/serializers/transaction_upload_serializer.rb`

**Serialized Attributes:**
- Core: id, organization_id, status
- Stats: total_rows, processed_rows, failed_rows
- Error: error_message
- Timestamps: processing_started_at, processing_completed_at, created_at, updated_at
- File: csv_file_url, csv_file_name

### 7. ActiveAdmin Interface

**File Created:**
- `app/admin/transaction_uploads.rb`

**Admin Features:**
- List view with filterable columns
- Show view with all details and download link
- Form for manual upload
- Status tags with color coding
- Organization filtering

### 8. Routes

**Added to `config/routes.rb`:**
```ruby
resources :transaction_uploads, only: [:index, :show, :create]
```
Under organizations namespace.

### 9. Documentation

**Files Created:**
- `doc/transaction_upload_format.md` - Complete CSV format documentation
- `doc/sample_transactions.csv` - Sample CSV file for testing
- `TRANSACTION_UPLOAD_SETUP.md` - This file

## Setup Instructions

### 1. Install Dependencies

```bash
docker-compose run web bundle install
```

### 2. Run Migrations

```bash
docker-compose run web bundle exec rails db:migrate
```

### 3. Start Services

```bash
docker-compose up -d
```

This will start:
- MySQL database
- Redis
- LocalStack (S3)
- Rails web server
- Sidekiq worker (processes uploads)
- Sidekiq scheduler

### 4. Verify S3 Bucket

The S3 bucket should be created automatically on Rails startup. You can verify by checking the logs:

```bash
docker-compose logs web | grep "S3 bucket"
```

You should see: `Created S3 bucket 'cvf-transactions'` or `S3 bucket 'cvf-transactions' already exists`

## Testing the Feature

### Via API

1. Create a cohort for the month you'll upload transactions for:
```bash
curl -X POST http://localhost:3000/api/v1/organizations/1/cohorts \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cohort_start_date": "2024-01-01",
    "planned_spend": 10000
  }'
```

2. Upload CSV:
```bash
curl -X POST http://localhost:3000/api/v1/organizations/1/transaction_uploads \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "csv_file=@doc/sample_transactions.csv"
```

3. Check upload status:
```bash
curl http://localhost:3000/api/v1/organizations/1/transaction_uploads/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Via ActiveAdmin

1. Navigate to http://localhost:3000/admin
2. Go to "Transaction Uploads"
3. Click "New Transaction Upload"
4. Select organization and upload CSV file
5. Monitor status and view results

## State Machine Flow

```
submitted → processing → processed
              ↓
           errored
```

- **submitted**: Initial state after upload creation
- **processing**: Job started, CSV being parsed
- **processed**: All rows successfully processed
- **errored**: One or more rows failed (or job crashed)

## Error Handling

The system handles errors at multiple levels:

1. **Validation Errors**: CSV format, file type
2. **Row-Level Errors**: Missing fields, invalid data, missing cohort
3. **Job-Level Errors**: File read errors, unexpected exceptions

All errors are logged and stored in the `error_message` field for debugging.

## Monitoring

- **Sidekiq Dashboard**: http://localhost:3000/sidekiq
- **ActiveAdmin**: http://localhost:3000/admin/transaction_uploads
- **Logs**: `docker-compose logs worker` for job execution logs

## Next Steps

To extend this feature, consider:

1. **Validation Rules**: Add custom validations for amount ranges, date ranges
2. **Notifications**: Email or webhook notifications on upload completion
3. **Batch Processing**: For very large files, process in batches
4. **Reporting**: Add analytics on upload success rates
5. **UI**: Build frontend interface for drag-and-drop upload
