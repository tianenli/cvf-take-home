module Api
  module V1
    class TxnsController < BaseController
      def index
        authorize_organization!(params[:organization_id])
        @txns = current_organization.txns.includes(:customer).order(payment_date: :desc)
        render json: @txns, each_serializer: TxnSerializer
      end

      def create
        authorize_organization!(params[:organization_id])
        @txn = current_organization.txns.build(txn_params)
        @txn.save!
        render json: @txn, serializer: TxnSerializer, status: :created
      end

      private

      def txn_params
        params.require(:txn).permit(:customer_id, :reference_id, :payment_date, :amount)
      end
    end
  end
end
