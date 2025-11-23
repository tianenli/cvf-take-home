module Api
  module V1
    class CohortsController < BaseController
      before_action :set_cohort, only: [:show, :update, :approve, :complete, :terminate]

      def index
        authorize_organization!(params[:organization_id])

        @cohorts = current_organization.cohorts
          .includes(:cohort_payments)
          .order(cohort_start_date: :desc)

        render json: @cohorts, each_serializer: CohortSerializer
      end

      def show
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def update
        @cohort.update!(cohort_params)
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def approve
        @cohort.approve!
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def complete
        @cohort.complete!
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def terminate
        @cohort.terminate!
        render json: @cohort, serializer: CohortDetailSerializer
      end

      private

      def set_cohort
        authorize_organization!(params[:organization_id])
        @cohort = current_organization.cohorts.find(params[:id])
        authorize_cohort!(@cohort.id)
      end

      def cohort_params
        params.require(:cohort).permit(:committed, :adjustment)
      end
    end
  end
end
