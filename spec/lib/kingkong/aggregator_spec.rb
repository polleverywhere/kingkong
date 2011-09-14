require 'spec_helper'
require "rspec/mocks/standalone"

describe KingKong::Aggregator do
  before(:all) do
    @agg = KingKong::Aggregator.new

    @pings = (1..3).map do |n|
      ping = KingKong::Ping.new
      ping.stub(:latency){ n.to_f }
      ping
    end

    @agg.process *@pings
  end

  it "should calculate avg" do
    @agg.avg.should eql(2.0)
  end

  it "should calculate sum" do
    @agg.sum.should eql(6.0)
  end

  it "should calculate max" do
    @agg.max.should eql(3.0)
  end

  it "should calculate min" do
    @agg.min.should eql(1.0)
  end
end