# frozen_string_literal: true

require_relative "latest_price_stock/version"
require_relative "latest_price_stock/models/stock"
require_relative "latest_price_stock/railtie"

module LatestPriceStock
  class Error < StandardError; end
  # Your code goes here...
end
