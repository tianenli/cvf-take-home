class TransactionUploadSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :status, :error_message, :error_details,
             :total_rows, :processed_rows, :failed_rows,
             :processing_started_at, :processing_completed_at,
             :created_at, :updated_at, :csv_file_url, :csv_file_name

  def csv_file_url
    return nil unless object.csv_file.attached?
    Rails.application.routes.url_helpers.rails_blob_path(object.csv_file, only_path: true)
  end

  def csv_file_name
    return nil unless object.csv_file.attached?
    object.csv_file.filename.to_s
  end

  def error_details
    object.error_details || []
  end
end
