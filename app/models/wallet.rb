class Wallet < ApplicationRecord
  belongs_to :wallet_type, polymorphic: true
end
