require 'eventmachine'

module KingKong
  # Provides access to the pinger via a Socket or TCP port so that other
  # services, like Munin for example, can graph the data.
  module Reporting
    class Server < EventMachine::Connection
      Terminator = "\n\n"
      Host = '/tmp/king_kong.socket'
      Port = nil

      attr_accessor :aggregators

      # Accept a collection of aggregators that we'll use to report our stats.
      def initialize(*aggregators)
        @aggregators = aggregators
      end

      # Dump out the stats and close down the connection
      def post_init
        begin
          send_data "#{aggregators.each(&:to_s).join("\n")}#{Terminator}"
        rescue => e
          send_data "Exception! #{e}\n#{e.backtrace}"
        ensure
          close_connection
        end
      end

      # A nice short-cut for peeps who aren't familar with EM to fire up
      # an Reporting server with an array of aggregators, host, and a port.
      def self.start(aggregators, host=Socket::Host, port=Socket::Port)
        EventMachine::start_server(host, port, self, aggregators)
      end
    end
  end
end