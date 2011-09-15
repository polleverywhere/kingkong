require "kingkong/version"

module KingKong
  autoload :Ping,       'kingkong/ping'
  autoload :Pinger,     'kingkong/pinger'
  autoload :Runner,     'kingkong/runner'
  autoload :Logging,    'kingkong/logging'
  autoload :Aggregator, 'kingkong/aggregator'

  # Default logger for KingKong.
  def self.logger
    @logger ||= Logger.new($stdout)
  end

  # Want to override the default logger? Its cool, change it up here.
  def self.logger=(logger)
    @logger = logger
  end

  # Shortcut for starting a runner
  def self.start(*args)
    Runner.new(*args)
  end
end