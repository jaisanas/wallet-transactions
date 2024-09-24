module LatestPriceStock
    class Railtie < Rails::Railtie
      initializer "latest_price_stock.load_migrations" do |app|
        # Add the gem's migrations to the Rails app's migration paths
        app.config.paths["db/migrate"].concat(Dir[File.expand_path('../migrations', __FILE__)])
      end
    end
  end