require 'eventmachine'

module KingKong
  # Encaspulates and calculates latency.
  class Ping
    attr_accessor :end_time, :ttl

    def initialize(ttl=30,sequencer=self.class.sequencer)
      # Time out is when the ping should give up!
      @ttl, @sequencer = ttl, sequencer
    end

    # Lazily grab a id
    def id
      @id ||= @sequencer.next
    end

    # When did the ping start? This is also what starts the time for this thing
    def start_time
      unless @start_time
        @start_time = current_time
      end
      @start_time
    end

    # Set the end time
    def pong
      @end_time ||= current_time
    end

    # How long did it take to clear the message?
    def latency
      end_time - start_time if end_time
    end

    # Did this get ponged yet?
    def completed?
      !!end_time
    end

    # Is this ping still on its journy? Will it make it back! It hasn't yet...
    def active?
      !timed_out? or !completed?
    end

    # Did we not receive a pong?
    def timed_out?
      start_time + ttl < current_time and not end_time
    end

    # Give us the current time in seconds
    def current_time
      Time.now.to_f
    end

    # Generates ids for pings
    def self.sequencer
      @sequencer ||= Sequencer.new
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
    def key(count=count)
      "#{count}:#{run}"
    end
  end

  # Add evented functionality to a ping so that it times out, etc.
  class Ping::Deferrable < Ping
    include EventMachine::Deferrable
    
    # Setup a ttl for the ping so that it will timeout after ttl seconds
    def start_time
      timeout(ttl) # Setup an em TTL on this thing so it fails if the thing isn't called
      super
    end

    # Succeed a block passed into the ping and mark the ping as suceeded
    def pong(&block)
      callback(&block) if block_given?
      super
      succeed self
    end
  end
end