source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'devise-two-factor', '>= 6.0'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails'
gem 'puma', '~> 5.6.5'
gem 'rails', '~> 7.0.10'
gem 'rexml'
gem 'rqrcode'
gem 'sass-rails', '>= 6'
gem 'simple_form'
gem 'simplecov', require: false, group: :test
gem 'sprockets-rails'
gem 'sqlite3', '~> 1.4'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'webpacker', '~> 5.4.3'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 5.1.2'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 3.39'
  gem 'factory_bot_rails'
  # >= 4.11 bundles Selenium Manager, which resolves chromedriver itself and
  # replaces the (now retired) webdrivers gem.
  gem 'selenium-webdriver', '>= 4.11'
end