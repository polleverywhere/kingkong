require 'eventmachine'
require 'nosey'

module KingKong
  class Pinger
    include Logging
    include Nosey::Instrumentation

    attr_reader :wait

    def initialize(wait=5,&block)
      @wait = wait
      @block = block if block_given?
      self
    end

    # Starts the pinger
    def start
      logger.debug "Starting pinger #{self}"
      @timer = EventMachine::PeriodicTimer.new(wait){ ping }
      ping # Start a ping right away, the timer above will fire later.
    end

    # Stop the pinger from executing
    def stop
      logger.debug "Stopping pinger #{self}"
      @timer.cancel if @timer
    end

  private
    # Add all of the instrumentation callbacks into the ping so we can aggregate it later
    def ping
      ping = Ping::Deferrable.new(Ping.default_ttl, sequencer)

      # Register the aggregator to process the ping
      ping.callback { 
        logger.debug "Ping #{ping} successful"
        process ping
      }

      ping.errback  {
        logger.debug "Ping #{ping} error (probably a timeout)"
        process ping
      }

      # Now pass the ping into the block so we can start/stop it
      @block.call(ping, self)
    end

    # Setup a squencer that's unique specifically to this pinger
    def sequencer
      @sequencer ||= Ping::Sequencer.new
    end

    # Process a stinkin ping and report aggregate stats to Nosey
    def process(ping)
      nosey.increment 'ping_count'
      case ping.status
      when :timed_out
        nosey.increment 'ping_timed_out_count'
      when :completed
        nosey.increment 'ping_completed_count'
        nosey.avg "ping_avg_latency", ping.latency
        nosey.min "ping_min_latency", ping.latency
        nosey.max "ping_max_latency", ping.latency
      end
    end
  end
end