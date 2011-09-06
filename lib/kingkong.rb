require "kingkong/version"

module KingKong
  autoload :Ping,       'kingkong/ping'
  autoload :Pinger,     'kingkong/pinger'
  autoload :Server,     'kingkong/server'
  autoload :Logging,    'kingkong/logging'
  autoload :Aggregator, 'kingkong/aggregator'

  # Default logger for KingKong.
  def self.logger
    @logger ||= Logger.new($stdout)
  end

  def self.logger=(logger)
    @logger = logger
  end
end