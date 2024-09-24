class WalletsController < ApplicationController
    before_action :authorize, only: [:index, :create, :create_team_wallet, :get_team_wallet]

    def index
        @wallets = current_user.wallets
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

    def create_team_wallet
        if current_user.user_type == "admin"
            team = current_user.team
            @wallet = Wallet.new(wallet_params)
            @wallet.wallet_type = team
            if @wallet.save!
                render json: @wallet
            else
                render json: { errors: "wallet is not created" }, status: :unprocessable_entity
            end
        else 
            render json: { errors: "You have unsufficient access" }, status: :unauthorized
        end
    end

    def get_team_wallet
        team = current_user.team
        @wallets = team.wallets
        render json: @wallets
    end 

    private
    def wallet_params
        params.require(:wallet).permit(:balance, :currency)
    end
end
