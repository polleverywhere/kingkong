require 'logger'

module KingKong
  # Logging concern for each class
  module Logging
    def logger
      KingKong.logger
    end
  end

  # Default logger for KingKong.
  def self.logger
    @logger ||= Logger.new($stdout)
  end
end