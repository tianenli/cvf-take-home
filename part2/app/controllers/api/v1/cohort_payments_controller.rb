module Api
  module V1
    class CohortPaymentsController < BaseController
      before_action :set_organization
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

      def set_organization
        @organization = Organization.find(params[:organization_id])
      end

      def set_cohort
        @cohort = @organization.cohorts.find(params[:cohort_id])
      end
    end
  end
end
