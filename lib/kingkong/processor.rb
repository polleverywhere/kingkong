require 'nosey'

module KingKong
  module Processor
    # Base class for processing pings
    class Base
      # Enable block configurations
      def initialize(&block)
        block.call(self) if block_given?
        self
      end

      def process(ping)
        raise 'Not Implemented'
      end
    end

    class Nosey < Base
      def initialize(host='/tmp/kingkong.socket',port=nil)
        EventMachine::Nosey::SocketServer.start(nosey.report, host, port)
      end

      def process(ping,name)
        nosey.increment "#{name}_ping_count"
        case ping.status
        when :timed_out
          nosey.increment "#{name}_ping_timed_out_count"
        when :completed
          nosey.increment "#{name}_ping_completed_count"
          nosey.avg "#{name}_ping_avg_latency", ping.latency
          nosey.min "#{name}_ping_min_latency", ping.latency
          nosey.max "#{name}_ping_max_latency", ping.latency
        end
      end
      
      def nosey
        @nosey ||= ::Nosey::Probe::Set.new('pinger')
      end
    end

    class Cube < Base
      include Logging

      attr_accessor :url
      
      # TODO use web sockets ...
      def process(ping, name)
        http = EM::HttpRequest.new(url).post({
          :body => Yajl::Encoder.encode([cube_hash(ping, name)]),
          :head => {'content-type' => 'application/json'}
        })
        http.callback{
          case http.response_header.status
          when 200..204
            logger.debug "Successfully reported to Cube at #{url}"
          else
            logger.error "Could not report to Cube server: HTTP #{http.response_header.status} : #{http.response}"
          end
        }
        http.errback{
          logger.error "Could not connect to Cube at #{url}"
        }
      end

    private
    # Bust out a hash that cube will understand as JSON
      def cube_hash(ping, name)
        {
          'type' => name.to_s,
          'time' => Time.now.iso8601,
          'data' => ping.to_hash
        }
      end
    end
  end
end