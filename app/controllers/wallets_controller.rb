class WalletsController < ApplicationController
    before_action :authorize, only: [:index, :create]

    def index
        @wallets = Wallet.all
        render json: @wallets
    end

    def create
        @wallet = Wallet.new(wallet_params)
        user = User.find(current_user.id)
        @wallet.wallet_type = user
    
        if @wallet.save!
            render json: @wallet
        else
            render json: { errors: "wallet is not created" }, status: :unprocessable_entity
        end
    end

    private
    def wallet_params
        params.require(:wallet).permit(:balance, :currency)
    end
end
