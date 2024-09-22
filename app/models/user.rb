class User < ApplicationRecord
    has_secure_password

    belongs_to :team, optional: true
    has_many :wallets, as: :wallet_type
    validates :email, presence: true
end
