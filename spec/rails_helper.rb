# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'webdrivers/chromedriver'
require 'rspec/rails'
require 'factory_bot_rails'
require 'capybara/rspec'
require 'capybara/rails'

Capybara.javascript_driver = :selenium
Capybara.default_driver = :rack_test
Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless') unless ENV['NO_HEADLESS']
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--remote-debugging-port=9222')
  options.add_argument("-user-agent='Capybara Automated Tests'")
  options.add_argument('--use-fake-device-for-media-stream')
  options.add_argument('--use-fake-ui-for-media-stream')

  opts = {browser: :chrome, options: options}
  opts[:service] = Selenium::WebDriver::Service.chrome(path: '/bin/chromedriver') if File.exist?('/bin/chromedriver')
  Capybara::Selenium::Driver.new(app, **opts)
end

Capybara.server = :puma, {Silent: true}

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.example_status_persistence_file_path = '.rspec-failures'
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
