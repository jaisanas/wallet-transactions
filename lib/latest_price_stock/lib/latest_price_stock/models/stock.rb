module LatestStockPrice
    class Stock < ActiveRecord::Base
      validates :name, presence: true
      validates :price, presence: true
      validates :description, presence: true
      validates :status, presence: true
    end
end