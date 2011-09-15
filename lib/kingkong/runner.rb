require 'nosey'

module KingKong
  # Configure multiple pingers to run
  class Runner
    include Logging

    # Array of pingers that we're running
    def ping(name, &block)
      DSL::Pinger.new(&block).completed do |pinger|
        pinger.nosey.name = name.to_s
        pingers << pinger
      end
    end

    # Setup the socket that this thing will write stats out to
    def socket(host='/tmp/king_kong.socket', port=nil)
      @socket_host , @socket_port = host, port
    end

    # Start all of the pingers given the configurations
    def start
      start_socket
      start_pingers
    end

    # Stop all of the pingers
    def stop
      pingers.each(&:stop)      
    end

    # Open up the configuration DSL for this puppy
    def configure(&block)
      block.arity > 1 ? block.call(self) : instance_eval(&block)
      self
    end

    # Shortcut for creating a new class and configuring it
    def self.configure(&block)
      new.configure(&block)
    end

    # Shortcut for configuring and starting a KingKong runner
    def self.run(&block)
      ensure_running_reactor { 
        runner = configure(&block)
        runner.start
      }
      runner # For chaining
    end

  private
    # Fire up the reporting server if a socket (and port, optionally) are given
    def start_socket
      EM::Nosey::SocketServer.start(nosey_report, @socket_host, @socket_port) if @socket_host
    end

    # Get us the nosey report that our nosey socket needs to get the job done son!
    def nosey_report
      Nosey::Report.new do |r|
        r.probe_sets = pingers.map(&:nosey)
      end
    end

    # Fire up all the pingers
    def start_pingers
      pingers.each(&:start)
    end

    # Create instances of pingers from the configurations that we setup in the runner
    def pingers
      @pingers ||= []
    end

    def self.ensure_running_reactor(&block)
      EM.reactor_running? ? block.call : EM.run(&block)
    end
  end

  class Runner
    module DSL
      # Encapsulate the configuration of a bunch of pingers that we can run in one KingKong file
      class Pinger
        # Time units expressed in seconds
        module Unit
          Second  = 1
          Minute  = 60
          Hour    = 60 * 60
        end

        attr_accessor :block

        def every(quantity)
          @quantity = quantity
          self
        end

        # Configure duration as seconds
        def seconds(&block)
          unitize Unit::Second, &block
          complete
        end
        alias :second :seconds

        # Configure the duration as minutes
        def minutes(&block)
          unitize Unit::Minute, &block
          complete
        end
        alias :minute :minutes

        # Configure the ping duration as hours
        def hours(&block)
          unitize Unit::Hour, &block
          complete
        end
        alias :hour :hours

        # The number of seconds the timer will wait between ticks. We'll pass this into EM
        def duration
          @units * @quantity
        end

        # Return a configured instance of a pinger that we can fire up and do stuff with
        def pinger
          KingKong::Pinger.new(duration, &@block)
        end

        # Callback when we've completed the configuration of this thing.
        def completed(&block)
          @completed_blk = block
          self
        end

      private
        # Figures out the number of seconds that we multply by the units
        def unitize(units, &block)
          @units = units
          @block = block
          self
        end

        # Yay! Its complete!
        def complete
          @completed_blk.call(pinger) if @completed_blk
          self
        end
      end
    end
  end
end