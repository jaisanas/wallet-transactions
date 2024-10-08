class TransactionsController < ApplicationController
    before_action :authorize, only: [:index, :create, :histories]

    # == Description
    #   This method will provide api to get current user's transactions list
    #
    # == Parameters:
    #
    # == Logic:
    #   Initialize empty array to accomodate result
    #   Get all wallets that is associated to current_user
    #   Iterate each wallet 
    #   Query all transactions where wallet id is equal to from_wallet_id or to_wallet_ud
    #   Append the result
    #
    # == Returns:
    #   If object is sucessfully created in db record, it will render transactions json array object
    #   If failed then it will return error with error message
    def index
        @transaction_histories = []
        wallets = current_user.wallets
        wallets.each do |wallet|
            transactions = Transaction.where("from_wallet_id = ? OR to_wallet_id = ?", wallet.id, wallet.id)
            @transaction_histories.concat(transactions)
        end

        render json: @transaction_histories
    end

    # == Description
    #   This method will provide api to get current user's transactions list
    #
    # == Parameters:
    #
    # == Logic:
    #   Initialize empty array to accomodate result
    #   Get all wallets that is associated to current_user
    #   Iterate each wallet 
    #   Query all transactions where wallet id is equal to from_wallet_id or to_wallet_ud
    #   Append the result
    #
    # == Returns:
    #   If object is sucessfully created in db record, it will render transactions json array object
    #   If failed then it will return error with error message
    def histories
        @transaction_histories = []
        wallets = current_user.wallets
        wallets.each do |wallet|
            transactions = Transaction.where("from_wallet_id = ? OR to_wallet_id = ?", wallet.id, wallet.id)
            @transaction_histories.concat(transactions)
        end

        render json: @transaction_histories
    end

    # == Description
    #   This method will provide api to create new transaction
    #
    # == Parameters:
    # from_wallet_id::
    #   Wallet id sender (Integer)
    # to_wallet_id::
    #   Wallet id recipient (Integer)
    # amount::
    #   Amount that will be deducted from wallet sender (Decimal)
    # trasaction_type::
    #   Type of transaction that is allowed: transfer, topup, withdraw, purchase, refund
    #
    # == Logic:
    #   Sanitized parameter input, only model's attributes
    #   Check transaction type
    #   If transaction_type is equal to transfer then execute transfer logic
    #   If transaction_type is equal to topup then execute topup logic
    #   If transaction_type is equal to withdraw then execute withdraw logic
    #   If transaction_type is equal to purchase then execute purchase logic
    #   If transaction_type is equal to refund then execute refund logic
    #
    # == Returns:
    #   If object is sucessfully created in db record, it will render success message object
    #   If failed then it will return error with error message
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

    # == Description
    #   This method will provide functionality to transfer 
    #
    # == Parameters:
    #from_wallet_id::
    #   Wallet id sender (Integer)
    #to_wallet_id::
    #   Wallet id recipient (Integer)
    #transferred_amount::
    #   Amount that will be deducted from wallet sender (Decimal)
    #
    # == Logic:
    #   Sanitized parameter input, only model's attributes
    #   Reduce sender balance with transferred_amount
    #   If deducted balance is less than 0 then we cannot proceed transfer
    #   Increase recipient balance with transfered amount
    #   Update recipient balance, sender balance inside sql transactions
    #   Inside sql transaction create new transaction record
    #
    # == Returns:
    #   If object is sucessfully created in db record, it will render success message object
    #   If failed then it will return error with error message
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

    # == Description
    # This method will provide functionality to topup balance 
    #
    # == Parameters:
    #to_wallet_id::
    #   Wallet id recipient (Integer)
    #topup_amount::
    #   Amount that will be top up (Decimal)
    #
    # == Logic:
    #   Sanitized parameter input, only model's attributes
    #   Increase recipient balance with topup_balance
    #   Inside sql transaction execute query update balance and create new transaction
    #
    # == Returns:
    #   If object is sucessfully created in db record, it will render success message object
    #   If failed then it will return error with error message
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

    # == Description
    # This method will provide functionality to withdraw balance 
    #
    # == Parameters:
    # from_wallet_id::
    #   Wallet id that some of money will be withdrawn (Integer)
    # withdraw_amount::
    #   Amount that will be withdrawn (Decimal)
    #
    # == Logic:
    #   Sanitized parameter input, only model's attributes
    #   Reduce sender's balance with withdraw_amount
    #   Inside sql transaction execute query update balance and create new transaction
    #
    # == Returns:
    #   If object is sucessfully created in db record, it will render success message object
    #   If failed then it will return error with error message
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

    # == Description
    #   This method will provide functionality to purchase stock 
    #
    # == Parameters:
    # from_wallet_id::
    #   Wallet id sender (Integer)
    # to_wallet_id::
    #   Wallet id recipient (Stock wallet) (Integer)
    # transferred_amount::
    #   Amount that will be deducted from wallet sender (Stock wallet)(Decimal)
    #
    # == Logic:
    #   Sanitized parameter input, only model's attributes
    #   Reduce sender balance with transferred_amount
    #   If deducted balance is less than 0 then we cannot proceed purchase
    #   If transfer_amount is less than stock's we cannot proceed purchase
    #   Increase recipient balance (stock's wallet balance) with transfered amount
    #   Update recipient balance, sender balance inside sql transactions
    #   Inside sql transaction create new transaction record
    #
    # == Returns:
    #   If object is sucessfully created in db record, it will render success message object
    #   If failed then it will return error with error message
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
