module KingKong
  # Processes and aggregates pings for reporting. These stats will probably
  # be accessed throug the KingKong::Server UNIX socket.
  class Aggregator
    attr_reader :sum, :max_count, :pings, :started_at

    def initialize(max_count=10)
      @max_count = max_count
      reset
    end

    # Accept a ping message, keep a running total, and make sure we stay within the
    # size of the number of samples that we want to keep around.
    def process(ping)
      @sum+=ping.latency
      pings.push ping

      # Take out the old ping if we're approaching our max sample size and substruct it
      # from the running latency sum
      if count > max_count and ping = pings.shift
        @sum-=ping.latency
      end
    end

    # Average latency of pings
    def avg
      count.zero? ? 0  : sum / count
    end

    # Number of pings
    def count
      pings.size
    end

    # Basic statistical summary of ping latency
    def to_hash
      {
        :avg => avg,
        :count => count,
        :sum => sum,
        :started_at => started_at
      }
    end

    def to_s
      to_hash.to_yaml
    end

    # Reset all of the counts to 0 and empty all of the pings
    def reset
      @sum        = 0
      @pings      = Array.new
      @started_at = Time.now
    end
  end
end