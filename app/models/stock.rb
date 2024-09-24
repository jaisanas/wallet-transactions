class Stock < ApplicationRecord
    has_one :wallet, as: :wallet_type
end
