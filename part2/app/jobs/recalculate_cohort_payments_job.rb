class RecalculateCohortPaymentsJob < ApplicationJob
  def perform(cohort_id)
    cohort = Cohort.find(cohort_id)

    # Find all unique months where transactions occurred
    months_with_payments = cohort.txns.pluck(:payment_date).map do |date|
      ((date.year - cohort.cohort_start_date.year) * 12) +
      (date.month - cohort.cohort_start_date.month)
    end.uniq.sort

    # Recalculate each month's payment
    months_with_payments.each do |months_after|
      UpdateCohortPaymentJob.new.perform(cohort_id, months_after)
    end
  end
end
