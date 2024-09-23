class TransactionsController < ApplicationController
    before_action :authorize, only: [:index, :create]

    def index
        @transactions = Transaction.all
        render json: @transactions
    end

    def create
        @transaction = Transaction.new(transaction_params)
        @transaction.deducted_at = Time.now
        if @transaction.save!
            render json: @transaction
        else
            render json: { errors: "wallet is not created" }, status: :unprocessable_entity
        end
    end

    private
    def transaction_params
        params.require(:transaction).permit(:from_wallet_id, :to_wallet_id, :amount, :transaction_type)
    end
end
