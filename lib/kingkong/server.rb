module KingKong
  # Opens a UNIX socket to report pinger statistics
  class Server < EventMachine::Connection
    Frame = "\r\n"

    def initialize(pinger)
      @pinger = pinger
    end

    def post_init
      send_data frame @pinger.aggregator.to_hash.to_yaml
    end

    # Start an instance of the aggregator server on a unix port
    def self.start(pinger, host='/tmp/kingkong.socket', port=nil)
      EM.start_server host, port, self, pinger
    end

  private
    def frame(message)
      "#{message}#{Frame}"
    end
  end
end