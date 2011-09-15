require 'bundler/setup'
require 'kingkong'
require 'eventmachine'
require 'logger'
require 'em-ventually'

RSpec.configure do |config|
  config.mock_framework = :rspec
end

module KingKong
  module Test
    # Read data from a socket and then kill it right away.
    class ReadSocket < EventMachine::Connection
      include EventMachine::Deferrable

      def receive_data(data)
        buffer << data
      end

      def unbind
        succeed buffer
      end

      def self.start(host,port=nil)
        EventMachine::connect host, port, self
      end

    private
      def buffer
        @buffer ||= ""
      end
    end
  end
end

# Squelch the logger so we can see our specs passing
KingKong.logger = Logger.new('/dev/null')