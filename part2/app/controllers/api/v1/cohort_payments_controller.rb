module Api
  module V1
    class CohortPaymentsController < BaseController
      before_action :set_cohort

      def index
        @cohort_payments = @cohort.cohort_payments.order(:months_after)
        render json: @cohort_payments, each_serializer: CohortPaymentSerializer
      end

      def show
        @cohort_payment = @cohort.cohort_payments.find(params[:id])
        render json: @cohort_payment, serializer: CohortPaymentSerializer
      end

      private

      def set_cohort
        authorize_organization!(params[:organization_id])
        @cohort = current_organization.cohorts.find(params[:cohort_id])
        authorize_cohort!(@cohort.id)
      end
    end
  end
end
