ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# concurrent-ruby 1.3.5 dropped its transitive `require "logger"`, which
# ActiveSupport < 7.1 depended on. Remove once on Rails 7.1+.
require 'logger'

require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
