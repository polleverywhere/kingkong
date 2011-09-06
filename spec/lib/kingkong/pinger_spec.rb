require 'spec_helper'

describe KingKong::Pinger do
    include EM::Ventually

    before(:all) do
      @pinger = KingKong::Pinger.new
    end

    it "should start pinging" do
      @pinger.start
    end

    it "should stop pinging" do
      @pinger.stop
    end

    it "should sequence pings"
end