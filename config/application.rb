require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# dotenv-rails is only in the development and test groups, so the constant does
# not exist in production. Loaded here rather than left to the railtie so that
# .env is in place before the configuration below reads ENV.
Dotenv::Rails.load if defined?(Dotenv::Rails)

module DeviseOtpSecondStep
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Keys for the Rails encrypted attribute that devise-two-factor 5+ uses to
    # store the OTP secret. Set here rather than in an initializer because
    # Active Record reads them while its railtie boots, before config/initializers
    # is loaded. A real application would use encrypted credentials instead.
    config.active_record.encryption.primary_key = ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
    config.active_record.encryption.deterministic_key = ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY']
    config.active_record.encryption.key_derivation_salt = ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
