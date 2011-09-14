require 'spec_helper'
require 'timecop'

describe KingKong::Ping do
  it "should have default 30 second ttl" do
    KingKong::Ping.new.ttl.should eql(KingKong::Ping.default_ttl)
  end

  context "active" do
    before(:each) do
      @ping = KingKong::Ping.new      # Open up a pinger
      Timecop.freeze(@now = Time.now) # Freeze time
    end

    after(:each) do
      Timecop.return # Turn Timecop off
    end

    it "should start" do
      @ping.start.should eql(@now)
    end

    it "should be active" do
      @ping.start
      @ping.should be_active
    end

    it "should not be timed out" do
      @ping.start
      @ping.should_not be_timed_out
    end

    it "should not be completed" do
      @ping.start
      @ping.should_not be_completed
    end

    it "should raise exception if stopped but not started" do
      lambda{
        @ping.stop
      }.should raise_exception(KingKong::Ping::NotStartedError)
    end
  end

  context "timed out" do
    before(:all) do
      @ping = KingKong::Ping.new
      @span = KingKong::Ping.default_ttl + 1

      Timecop.freeze(@now = Time.now)       # Freeze now
      @ping.start                           # Start the ping
      Timecop.freeze(@then = @now + @span)  # Move to a timed-out state, and freeze again
    end

    after(:all) do
      Timecop.return # Turn Timecop off
    end

    it "should not have end time" do
      @ping.end_time.should be_nil
    end

    it "should be timed out" do
      @ping.should be_timed_out
    end

    it "should not be active" do
      @ping.should_not be_active
    end

    it "should not be completed" do
      @ping.should_not be_completed
    end
  end

  context "success" do
    before(:all) do
      @ping = KingKong::Ping.new
      @span = KingKong::Ping.default_ttl - 1 # 1 under the timeout

      Timecop.freeze(@now = Time.now)         # Freeze time
      @ping.start                             # Start the ping
      Timecop.freeze(@then = @now + @span)    # Move forward into time whene the ping is successful
      @ping.stop                              # End the ping
    end

    after(:all) do
      Timecop.return # Turn Timecop off
    end

    it "should stop" do
      @ping.stop.should eql(@then)
    end

    it "should have end time" do
      @ping.end_time.should eql(@then)
    end

    it "should calculate latency" do
      @ping.latency.should eql(@then - @now)
    end

    it "should not be active" do
      @ping.should_not be_active
    end

    it "should be completed" do
      @ping.should be_completed
    end
  end
end

describe KingKong::Ping::Deferrable do
  include EM::Ventually

  it "should time out" do
    @ping = KingKong::Ping::Deferrable.new(0.1)
    @ping.start
    @ping.errback{ @err_status = :timed_out }
    ly(:timed_out){ @err_status }
  end

  it "should callback with a ping if successful" do
    @ping = KingKong::Ping::Deferrable.new
    @ping.start
    @ping.stop
    @ping.callback{ |ping| @response = ping }
    ly{ KingKong::Ping }.test{|type| @response.kind_of? type }
  end
end

describe KingKong::Ping::Sequencer do
  before(:all) do
    @sequencer = KingKong::Ping::Sequencer.new(0)
  end

  it "should sequence" do
    count, run = @sequencer.next.split(':')
    count.should eql("1")
    run.should eql("0")
  end
end