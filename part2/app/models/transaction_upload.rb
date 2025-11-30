class TransactionUpload < ApplicationRecord
  include AASM

  # Associations
  belongs_to :organization
  has_one_attached :csv_file

  # Validations
  validates :status, presence: true
  validate :csv_file_must_be_present
  validate :csv_file_must_be_csv

  # Callbacks
  after_create :enqueue_processing_job

  # AASM State Machine
  aasm column: :status do
    state :submitted, initial: true
    state :processing
    state :processed
    state :errored

    event :start_processing do
      transitions from: :submitted, to: :processing, after: :set_processing_started_at
    end

    event :mark_processed do
      transitions from: :processing, to: :processed, after: :set_processing_completed_at
    end

    event :mark_errored do
      transitions from: [:submitted, :processing], to: :errored, after: :set_processing_completed_at
    end
  end

  private

  def csv_file_must_be_present
    unless csv_file.attached?
      errors.add(:csv_file, "must be attached")
    end
  end

  def csv_file_must_be_csv
    if csv_file.attached? && !csv_file.content_type.in?(['text/csv', 'text/plain', 'application/vnd.ms-excel'])
      errors.add(:csv_file, "must be a CSV file")
    end
  end

  def enqueue_processing_job
    ProcessTransactionUploadJob.perform_async(id)
  end

  def set_processing_started_at
    self.processing_started_at = Time.current
  end

  def set_processing_completed_at
    self.processing_completed_at = Time.current
  end
end
