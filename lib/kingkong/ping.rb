require 'eventmachine'

module KingKong
  # Encaspulates and calculates latency.
  class Ping
    NotStartedError= Class.new(RuntimeError)

    attr_accessor :end_time, :start_time, :ttl

    def initialize(ttl=self.class.default_ttl,sequencer=self.class.sequencer)
      # Time out is when the ping should give up!
      @ttl, @sequencer = ttl, sequencer
    end

    # Lazily grab a id
    def id
      @id ||= @sequencer.next
    end

    # Start the ping and set a start time
    def start
      @start_time ||= current_time
    end
    alias :ping :start

    # Stop the ping and set a stop time
    def stop
      raise Ping::NotStartedError.new("The ping must be started to stop") unless @start_time
      # We have a start time? Cool! Lets stop this thing then
      @end_time ||= current_time
    end
    alias :pong :stop

    # How long did it take to clear the message?
    def latency
      end_time.to_f - start_time.to_f if end_time
    end

    # Figure out the state of this ping.
    def status
      if !end_time and !start_time
        :not_started
      elsif start_time and !end_time and start_time + ttl < current_time
        :timed_out
      elsif start_time and !end_time
        :active
      elsif start_time and end_time
        :completed
      end
    end

    # Did this get ponged yet?
    def completed?
      status == :completed
    end

    # Is this ping still on its journy? Will it make it back! It hasn't yet...
    def active?
      status == :active
    end

    # Did we not receive a pong?
    def timed_out?
      status == :timed_out
    end

    # Nothing happened ye
    def not_started?
      status == :not_started
    end

    def to_s
      "Ping(#{id}, :#{status}#{", #{latency}s" if completed?})"
    end

    # Generates ids for pings
    def self.sequencer
      @sequencer ||= Sequencer.new
    end

    # Default TTL. Override this method if you want a different default.
    def self.default_ttl
      30 # 30 seconds that is!
    end

    # Bust out a hash so that we can encode it into JSON and make some magic happen.
    def to_hash
      {
        'status' => status,
        'latency' => latency,
        'start_time' => (start_time.iso8601 if start_time),
        'end_time' => (end_time.iso8601 if end_time),
        'ttl' => ttl
      }
    end

  private
    # Give us the current time in seconds
    def current_time
      Time.now
    end
  end

  # Keeps track of the results heading in/out. We could just use 
  # some totally random GUID instead of bothering with this, but 
  # having a 1,2,3... sequence makes it much easier to spot check
  # tests to verify whether or not messages are being sent correctly.
  class Ping::Sequencer
    attr_reader :count, :run

    def initialize(run=Time.now.to_i)
      @run, @count = run, 0
    end

    # Tick up the restul count and give us the key
    def next
      key @count += 1
    end

  private
    # Spits out a key and run for a result
    def key(count=count())
      "#{count}:#{run}"
    end
  end

  # Add evented functionality to a ping so that it times out, etc.
  class Ping::Deferrable < Ping
    include EventMachine::Deferrable
    
    # Setup a ttl for the ping so that it will timeout after ttl seconds
    def start
      timeout(ttl) # Setup an em TTL on this thing so it fails if the thing isn't called
      super
    end

    # Succeed a block passed into the ping and mark the ping as suceeded
    def stop(&block)
      callback(&block) if block_given?
      super
      succeed self
    end
  end
end