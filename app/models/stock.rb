class Stock < ApplicationRecord
    has_one :sawallet, as: :wallet_type
end
