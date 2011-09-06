require 'logger'

module KingKong
  # Logging concern for each class
  module Logging
    def logger
      KingKong.logger
    end
  end
end