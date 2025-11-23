module Api
  module V1
    class OrganizationsController < BaseController
      def index
        # Users can only see their own organization
        @organizations = [current_organization]
        render json: @organizations, each_serializer: OrganizationSerializer
      end

      def show
        authorize_organization!(params[:id])
        @organization = current_organization
        render json: @organization, serializer: OrganizationDetailSerializer
      end
    end
  end
end
