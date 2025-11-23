module Api
  module V1
    class FundsController < BaseController
      def index
        @funds = Fund.all
        render json: @funds, each_serializer: FundSerializer
      end

      def show
        @fund = Fund.find(params[:id])
        render json: @fund, serializer: FundSerializer
      end
    end
  end
end
