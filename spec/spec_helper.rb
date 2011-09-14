require 'bundler/setup'
require 'kingkong'
require 'eventmachine'
require 'logger'
require 'em-ventually'

RSpec.configure do |config|
  config.mock_framework = :rspec
end

# Squelch the logger so we can see our specs passing
KingKong.logger = Logger.new('/dev/null')