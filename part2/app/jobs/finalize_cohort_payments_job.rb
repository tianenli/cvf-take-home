class FinalizeCohortPaymentsJob < ApplicationJob
  queue_as :scheduler

  def perform
    # Find all cohort payments that are in computing state and
    # haven't been updated in the last 24 hours (indicating they're stable)
    CohortPayment.where(status: 'computing')
      .where('updated_at < ?', 24.hours.ago)
      .find_each do |cohort_payment|
        cohort_payment.finalize! if cohort_payment.may_finalize?
      end
  end
end
