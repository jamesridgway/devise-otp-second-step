source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'devise-two-factor', '>= 6.0'
gem 'importmap-rails'
gem 'jbuilder', '~> 2.7'
gem 'propshaft'
gem 'puma', '>= 6.0'
gem 'rails', '~> 8.1.3'
gem 'rexml'
gem 'rqrcode'
gem 'simple_form'
gem 'simplecov', require: false, group: :test
gem 'sqlite3', '>= 2.1'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails', '>= 6.1'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
end

group :test do
  gem 'capybara', '>= 3.39'
  gem 'factory_bot_rails'
  # >= 4.11 bundles Selenium Manager, which resolves chromedriver itself and
  # replaces the (now retired) webdrivers gem.
  gem 'selenium-webdriver', '>= 4.11'
end