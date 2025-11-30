require 'csv'

class ProcessTransactionUploadJob < ApplicationJob
  def perform(transaction_upload_id)
    transaction_upload = TransactionUpload.find(transaction_upload_id)

    begin
      # Transition to processing state
      transaction_upload.start_processing!

      # Download and parse CSV
      csv_content = transaction_upload.csv_file.download
      csv_data = CSV.parse(csv_content, headers: true)

      transaction_upload.update!(total_rows: csv_data.size)

      processed_count = 0
      failed_count = 0
      error_details = []
      affected_cohort_ids = Set.new

      csv_data.each_with_index do |row, index|
        row_number = index + 2 # Account for header row and 1-based indexing
        begin
          cohort_id = process_transaction_row(transaction_upload.organization, row, row_number)
          affected_cohort_ids.add(cohort_id) if cohort_id
          processed_count += 1
        rescue => e
          failed_count += 1
          error_detail = {
            row: row_number,
            reference_id: row['reference_id']&.strip,
            customer_id: row['customer_id']&.strip,
            error: e.message
          }
          error_details << error_detail
          Rails.logger.error("Error processing row #{row_number}: #{e.message}")
        end
      end

      transaction_upload.update!(
        processed_rows: processed_count,
        failed_rows: failed_count,
        error_details: error_details
      )

      # Enqueue cohort payment recalculation jobs for affected cohorts
      affected_cohort_ids.each do |cohort_id|
        RecalculateCohortPaymentsJob.perform_async(cohort_id)
      end

      # If any rows failed, mark as errored
      if failed_count > 0
        # Create summary error message
        error_message = "#{failed_count} row(s) failed to process. See error_details for specifics."
        transaction_upload.update!(error_message: error_message)
        transaction_upload.mark_errored!
      else
        transaction_upload.mark_processed!
      end

    rescue => e
      Rails.logger.error("Error processing transaction upload #{transaction_upload_id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      transaction_upload.update!(error_message: e.message)
      transaction_upload.mark_errored!
    end
  end

  private

  def process_transaction_row(organization, row, row_number)
    # Extract data from CSV row
    customer_reference_id = row['customer_id']&.strip
    payment_date_str = row['payment_date']&.strip
    amount_str = row['amount']&.strip
    txn_reference_id = row['reference_id']&.strip || "#{customer_reference_id}-#{payment_date_str}-#{amount_str}"

    # Validate required fields
    raise "Missing customer_id" if customer_reference_id.blank?
    raise "Missing payment_date" if payment_date_str.blank?
    raise "Missing amount" if amount_str.blank?

    # Parse date and amount
    payment_date = Date.parse(payment_date_str)
    amount = BigDecimal(amount_str)

    # Find cohort based on payment date (cohort is the month of payment rounded down)
    cohort_start_date = payment_date.beginning_of_month

    # Find or create cohort for this month
    cohort = organization.fund_organizations.first&.cohorts&.find_by(cohort_start_date: cohort_start_date)

    unless cohort
      raise "No cohort found for date #{cohort_start_date}. Please create cohort first."
    end

    # Find or create customer
    customer = cohort.customers.find_or_create_by!(reference_id: customer_reference_id)

    # Find or create transaction (idempotent - will update if exists)
    txn = Txn.find_or_initialize_by(
      organization: organization,
      reference_id: txn_reference_id
    )

    # Update transaction attributes
    txn.customer = customer
    txn.payment_date = payment_date
    txn.amount = amount
    txn.save!

    # Return cohort ID so it can be added to affected cohorts
    cohort.id
  end
end
