require 'spec_helper'

describe KingKong::Pinger do
  include EM::Ventually

  before(:all) do
    @@pinged = false
    @pinger = KingKong::Pinger.new(0.1) do |ping, pinger|
      @@ping = ping
      ping.start
      ping.stop
      pinger.stop
    end
  end

  it "should ping" do
    @pinger.start
    ly(:completed) { @@ping.status }
  end

  it "should stop"
  it "should start"

  context "ping aggregation" do
    it "should process timed-out"
    it "should process successful"
    it "should process errors"
  end
end