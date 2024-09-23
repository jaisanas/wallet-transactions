class User < ApplicationRecord
    belongs_to :team, optional: true
    has_many :wallets, as: :wallet_type
    has_secure_password
    validates :email, presence: true
end