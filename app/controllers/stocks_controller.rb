class StocksController < ApplicationController
    before_action :authorize, only: [:index]

    # == Description
    #   This method will provide functionality to list of stock stock 
    #
    # == Parameters:
    #
    # == Logic:
    #   Get list of stock
    #
    # == Returns:
    #   Return stock's json array objects
    def index
        @stocks = Stock.all
        render json: @stocks
    end
end
