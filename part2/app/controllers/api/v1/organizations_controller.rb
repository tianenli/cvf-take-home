module Api
  module V1
    class OrganizationsController < BaseController
      def index
        @organizations = Organization.includes(:fund_organizations, :funds).all
        render json: @organizations, each_serializer: OrganizationSerializer
      end

      def show
        @organization = Organization.includes(:fund_organizations, :cohorts).find(params[:id])
        render json: @organization, serializer: OrganizationDetailSerializer
      end
    end
  end
end
