module Api
  module V1
    class TransactionUploadsController < BaseController
      before_action :set_organization

      def index
        @transaction_uploads = @organization.transaction_uploads.order(created_at: :desc)
        render json: @transaction_uploads, each_serializer: TransactionUploadSerializer
      end

      def show
        @transaction_upload = @organization.transaction_uploads.find(params[:id])
        render json: @transaction_upload, serializer: TransactionUploadSerializer
      end

      def create
        @transaction_upload = @organization.transaction_uploads.new(transaction_upload_params)

        if @transaction_upload.save
          render json: @transaction_upload, serializer: TransactionUploadSerializer, status: :created
        else
          render json: { error: 'Failed to create transaction upload', details: @transaction_upload.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_organization
        @organization = Organization.find(params[:organization_id])
        authorize_organization!(params[:organization_id])
      end

      def transaction_upload_params
        params.permit(:csv_file)
      end
    end
  end
end
