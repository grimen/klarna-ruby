$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'klarna'

# Configuration.
Klarna.setup do |config|
  config.mode = :test

  config.country = :SE

  config.store_id = 2
  config.store_secret = 'lakrits'

  config.logging = true
  config.http_logging = false
end