module KingKong
  # Configure multiple pingers to run
  class Runner
    include Logging

    # Array of pingers that we're running
    def ping(name)
      pinger_configurations[name]
    end

    # Setup the socket that this thing will write stats out to
    def socket(host=KingKong::Reporting::Server::Host, port=KingKong::Reporting::Server::Port)
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
      Reporting::Server.start(pingers.map(&:aggregator), @socket_host, @socket_port) if @socket_host
    end

    # Fire up all the pingers
    def start_pingers
      pingers.each(&:start)
    end

    # Hang onto pinger configuration so that we can configure pinger instances and fire them
    # off. We'll also be using this for writing reports.
    def pinger_configurations
      @pinger_configurations ||= Hash.new{|hash,val| hash[val] = DSL::Pinger.new }
    end

    # Create instances of pingers from the configurations that we setup in the runner
    def pingers
      @pingers ||= pinger_configurations.values.map(&:pinger)
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
        end
        alias :second :seconds

        # Configure the duration as minutes
        def minutes(&block)
          unitize Unit::Minute, &block
        end
        alias :minute :minutes

        # Configure the ping duration as hours
        def hours(&block)
          unitize Unit::Hour, &block
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

      private
        # Figures out the number of seconds that we multply by the units
        def unitize(units, &block)
          @units = units
          @block = block
          self
        end
      end
    end
  end
end