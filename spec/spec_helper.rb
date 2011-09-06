require 'bundler/setup'
require 'kingkong'
require 'eventmachine'
require 'logger'
require 'em-ventually'

# Squelch the logger so we can see our specs passing
KingKong.logger = Logger.new('/dev/null')