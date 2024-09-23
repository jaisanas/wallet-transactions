class StocksController < ApplicationController
    before_action :authorize, only: [:index]

    def index
        @stocks = Stock.all
        render json: @stocks
    end
end
