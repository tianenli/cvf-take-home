class UpdateCohortPaymentJob < ApplicationJob
  def perform(cohort_id, months_after)
    cohort = Cohort.find(cohort_id)

    # Find or create cohort payment record
    cohort_payment = cohort.cohort_payments.find_or_initialize_by(months_after: months_after)

    # If it was finalized or settled, move back to computing
    cohort_payment.recompute! if cohort_payment.persisted? && !cohort_payment.computing?

    # Recalculate all values
    cohort_payment.calculate_revenue!
    cohort_payment.calculate_threshold_hit!
    cohort_payment.calculate_share_percentage!
    cohort_payment.calculate_total_owed!

    cohort_payment.save!
  end
end
