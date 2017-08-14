if ENV["START_SIMPLECOV"].to_i == 1
  require 'simplecov'
  SimpleCov.start
end

require "bundler/setup"
require "somleng/twilio_http_client"

RSpec.configure do |config|
  Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

  # Enable flags like --only-failures and --next-failure

  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
