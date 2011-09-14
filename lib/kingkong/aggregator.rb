module KingKong
  # Processes and aggregates samples for reporting. These stats will probably
  # be accessed throug the KingKong::Server UNIX socket.
  class Aggregator
    attr_reader :sum, :timed_out_count, :count, :started_at, :min, :max

    def initialize
      reset
    end

    # Accept a ping message, keep a running total, and make sure we stay within the
    # size of the number of samples that we want to keep around.
    def process(*pings)
      pings.each do |ping|
        @count+=1
        case ping.status
        when :timed_out
          @timed_out_count+=1
        else
          # This happens on our first ping before we have a min/max
          @min = @max = ping.latency if @min.nil? and @max.nil?
          # Cool! Lets do some math
          @min = ping.latency if ping.latency < @min
          @max = ping.latency if ping.latency > @max
          # We need to sum latency to calculate avgs
          @sum += ping.latency
        end
      end
    end

    # avg latency of samples
    def avg
      count.zero? ? 0  : sum / count
    end

    # What percentage of requests are timed out?
    def timed_out_percentage
      timed_out_count > 0 ? timed_out_count / count : 0
    end

    # Basic statistical summary of ping latency
    def to_hash
      {
        'started_at' => started_at,
        'avg' => avg,
        'sum' => sum,
        'min' => min,
        'max' => max,
        'count' => count,
        'timed_out_count' => timed_out_count,
        'successful_count' => count - timed_out_count
      }
    end

    # Print out a string for this that is suitable for flushing out to a socket
    def to_s
      to_hash.to_yaml
    end

    # Reset all of the counts to 0 and start sampling it all again!
    def reset
      @sum = 0.0
      @min = nil
      @max = nil
      @count = 0
      @timed_out_count = 0
      @samples = Array.new
      @started_at = Time.now
    end
  end
end