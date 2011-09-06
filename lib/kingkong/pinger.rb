require 'eventmachine'

module KingKong
  class Pinger
    include Logging

    attr_accessor :aggregator, :duration

    def initialize(duration=5)
      @duration = duration
    end

    # Starts the pinger
    def start(&block)
      logger.debug "Starting pinger #{self}"
      @timer = EventMachine::PeriodicTimer.new(duration){ ping(&block) }
      ping(&block)
    end

    # Stop the pinger from executing
    def stop
      logger.debug "Stopping pinger #{self}"
      @timer.cancel if @timer
    end

    # Gather up all the numbers we need for reporting later on
    def aggregator
      @aggregatore ||= Aggregator.new
    end
    
  private
    # Add all of the instrumentation callbacks into the ping so we can aggregate it later
    def ping(&block)
      ping = Ping::Deferrable.new(30, sequencer)
      # Register the aggregator to process the ping
      ping.callback { 
        logger.debug "Ping #{ping} successful"
        aggregator.process ping
      }
      ping.errback  {
        logger.debug "Ping #{ping} error (probably a timeout)"
        aggregator.process ping
      }
      # Now pass the ping into the block so we can start/stop it
      yield ping if block_given?
    end

    # Setup a squencer that's unique specifically to this pinger
    def sequencer
      @sequencer ||= Ping::Sequencer.new
    end
  end
end