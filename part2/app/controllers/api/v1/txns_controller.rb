module Api
  module V1
    class TxnsController < BaseController
      before_action :set_organization

      def index
        @txns = @organization.txns.includes(:customer).order(payment_date: :desc)
        render json: @txns, each_serializer: TxnSerializer
      end

      def create
        @txn = @organization.txns.build(txn_params)
        @txn.save!
        render json: @txn, serializer: TxnSerializer, status: :created
      end

      private

      def set_organization
        @organization = Organization.find(params[:organization_id])
      end

      def txn_params
        params.require(:txn).permit(:customer_id, :reference_id, :payment_date, :amount)
      end
    end
  end
end
