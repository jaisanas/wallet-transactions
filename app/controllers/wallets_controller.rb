class WalletsController < ApplicationController
    before_action :authorize, only: [:index, :create, :create_team_wallet, :get_team_wallet]

    # == Description
    # This method will provide api to get list of active's user wallets
    #
    # == Parameters:
    #
    # == Logic:
    # Find all wallets that is associated with user
    #
    # == Returns:
    # Return wallet object
    def index
        @wallets = current_user.wallets
        render json: @wallets
    end

    # == Description
    # This method will provide api to create active user's new wallet
    #
    # == Parameters:
    # balance::
    #   user's balance (Decimal)
    # currency::
    #   balance's currency (IDR, USD, ...) (String)
    #
    # == Logic:
    # Sanitized parameter input, only model's attributes
    # Create new wallet object from sanitized parameter input
    # Save object to execute active record and store in db
    #
    # == Returns:
    # If object is sucessfully created in db record, it will render wallet json object
    # If failed then it will return error with error message 
    def create
        @wallet = Wallet.new(wallet_params)
        @wallet.wallet_type = current_user
    
        if @wallet.save!
            render json: @wallet
        else
            render json: { errors: "wallet is not created" }, status: :unprocessable_entity
        end
    end

    # == Description
    # This method will provide api to create team's wallet
    #
    # == Parameters:
    # balance::
    #   user's balance (Decimal)
    # currency::
    #   balance's currency (IDR, USD, ...) (String)
    #
    # == Logic:
    # Sanitized parameter input, only model's attributes
    # Check if current is is admin
    # Create new wallet object from sanitized parameter input
    # Set wallet's association to team
    # Save object to execute active record and store in db
    #
    # == Returns:
    # If object is sucessfully created in db record, it will render wallet json object
    # If failed then it will return error with error message
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

    # == Description
    # This method will provide api to get team's wallet
    #
    # == Parameters:
    #
    # == Logic:
    # Get team from current user
    # Fetch all wallets that associated to the team
    #
    # == Returns:
    # Return wallet object json
    #
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
