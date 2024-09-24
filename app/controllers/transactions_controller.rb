class TransactionsController < ApplicationController
    before_action :authorize, only: [:index, :create, :histories]

    def index
        @transaction_histories = []
        wallets = current_user.wallets
        wallets.each do |wallet|
            transactions = Transaction.where("from_wallet_id = ? OR to_wallet_id = ?", wallet.id, wallet.id)
            @transaction_histories.concat(transactions)
        end

        render json: @transaction_histories
    end

    def histories
        @transaction_histories = []
        wallets = current_user.wallets
        wallets.each do |wallet|
            transactions = Transaction.where("from_wallet_id = ? OR to_wallet_id = ?", wallet.id, wallet.id)
            @transaction_histories.concat(transactions)
        end

        render json: @transaction_histories
    end

    def create
        case params[:transaction_type]
        when "transfer"
            validate_user(params[:from_wallet_id])
            transfer(params[:from_wallet_id], params[:to_wallet_id], params[:amount])
        when "topup"
            validate_user(params[:to_wallet_id])
            topup(params[:to_wallet_id], params[:amount])
        when "withdraw"
            validate_user(params[:from_wallet_id])
            withdraw(params[:from_wallet_id], params[:amount])
        when "purchase"
            validate_user(params[:from_wallet_id])
            purchase(params[:from_wallet_id], params[:to_wallet_id], params[:amount])
        when "refund"
            validate_user(params[:to_wallet_id])
            transfer(params[:from_wallet_id], params[:to_wallet_id], params[:amount])
        else 
            render json: { error: "Transaction type not found" }, status: :unprocessable_entity
        end
    end

    private
    def transaction_params
        params.require(:transaction).permit(:from_wallet_id, :to_wallet_id, :amount, :transaction_type)
    end

    def transfer(from_wallet_id, to_wallet_id, transferred_amount)
        debitted_wallet = Wallet.find(from_wallet_id)
        debitted_wallet_amount = debitted_wallet.balance - transferred_amount
        if debitted_wallet_amount < 0
            render json: { error: "Transfer is failed: insufficient balance" }, status: :unprocessable_entity
        end

        creditted_wallet = Wallet.find(to_wallet_id)
        creditted_wallet_amount = creditted_wallet.balance + transferred_amount

        Wallet.transaction do
            debitted_wallet.update(balance: debitted_wallet_amount)
            creditted_wallet.update(balance: creditted_wallet_amount)
            @transaction = Transaction.new(transaction_params)
            @transaction.deducted_at = Time.now
            @transaction.save!
        end
        render json: { message: "Transfer is success" }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
        render json: { error: "Transfer is failed: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
        render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end

    def topup(to_wallet_id, topup_amount)
        creditted_wallet = Wallet.find(to_wallet_id)
        creditted_wallet_amount = creditted_wallet.balance + topup_amount
        Wallet.transaction do
            creditted_wallet.update(balance: creditted_wallet_amount)
            @transaction = Transaction.new(transaction_params)
            @transaction.deducted_at = Time.now
            @transaction.save!
        end
        render json: { message: "Topup is success" }, status: :ok
        rescue ActiveRecord::RecordInvalid => e
            render json: { error: "Topup is failed: #{e.message}" }, status: :unprocessable_entity
        rescue StandardError => e
            render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end

    def withdraw(from_wallet_id, withdraw_amount)
        debitted_wallet = Wallet.find(from_wallet_id)
        debitted_wallet_amount = debitted_wallet.balance - withdraw_amount
        Wallet.transaction do
            debitted_wallet.update(balance: debitted_wallet)
            @transaction = Transaction.new(transaction_params)
            @transaction.deducted_at = Time.now
            @transaction.save!
        end
        render json: { message: "Withdraw is success" }, status: :ok
        rescue ActiveRecord::RecordInvalid => e
            render json: { error: "Withdraw is failed: #{e.message}" }, status: :unprocessable_entity
        rescue StandardError => e
            render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end

    def purchase(from_wallet_id, to_wallet_id, transferred_amount)
        debitted_wallet = Wallet.find(from_wallet_id)
        debitted_wallet_amount = debitted_wallet.balance - transferred_amount
        if debitted_wallet_amount < 0
            render json: { error: "Transfer is failed: insufficient balance" }, status: :unprocessable_entity
            return
        end
        creditted_wallet = Wallet.find(to_wallet_id)
        creditted_wallet_amount = creditted_wallet.balance + transferred_amount
        stock = creditted_wallet.wallet_type
        if transferred_amount < stock.price
            render json: { error: "Cannot purchase: insufficient amount" }, status: :unprocessable_entity
            return
        end
        Wallet.transaction do
            debitted_wallet.update(balance: debitted_wallet_amount)
            creditted_wallet.update(balance: creditted_wallet_amount)
            @transaction = Transaction.new(transaction_params)
            @transaction.deducted_at = Time.now
            @transaction.save!
        end
        render json: { message: "Purchase is success" }, status: :ok
        return
    rescue ActiveRecord::RecordInvalid => e
        render json: { error: "Transfer is failed: #{e.message}" }, status: :unprocessable_entity
        return
    rescue StandardError => e
        render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
        return
    end

    def validate_user(from_wallet_id)
        wallet = Wallet.find(from_wallet_id)
        user = wallet.wallet_type
        if user.id != current_user.id
            render json: { error: "User is not authorized to acces this wallet" }, status: :unauthorized
        end
    end
end
