class Team < ApplicationRecord
    has_many :wallets, as: :wallet_type
    has_many :users, dependent: :destroy
end
