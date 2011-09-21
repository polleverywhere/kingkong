require 'eventmachine'
require 'nosey'
require 'em-http-request'
require 'yajl'
require 'time'

module KingKong
  # Executes pings within a specificed duration.
  class Pinger
    include Logging
    include EventMachine::Deferrable
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

    # Fire this if when a ping completes
    def on_ping(&block)
      @on_ping = block
    end

  private
    # Add all of the instrumentation callbacks into the ping so we can aggregate it later
    def ping
      ping = Ping::Deferrable.new(Ping.default_ttl, sequencer)
      # Register the aggregator to process the ping
      ping.callback { 
        logger.debug "Ping #{ping}"
        @on_ping.call(ping) if @on_ping
      }
      ping.errback  {
        logger.debug "Ping #{ping}"
        @on_ping.call(ping) if @on_ping
      }
      # Now pass the ping into the block so we can start/stop it
      @block.call(ping, self)
    end

    # Setup a squencer that's unique specifically to this pinger
    def sequencer
      @sequencer ||= Ping::Sequencer.new
    end
  end
end