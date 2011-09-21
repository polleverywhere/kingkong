require 'spec_helper'
require 'socket'

describe KingKong::Runner do
  include EM::Ventually

  before(:each) do
    @@google_pinged = @@twitter_pinged = false

    @runner = KingKong::Runner.configure do |runner|
      runner.ping(:google).every(0.1).seconds do |ping|
        ping.start
        ping.stop
        @@google_pinged = true
      end

      runner.ping(:twitter).every(2).seconds do |ping|
        ping.start
        ping.stop
        @@twitter_pinged = true
      end
    end
  end

  it "should start pinging" do
    @runner.start
    ly(true) { @@google_pinged }
  end

  it "should write data to socket" do
    nosey = KingKong::Processor::Nosey.new('/tmp/king_kong_test.socket')

    @runner.on_pong do |ping, name|
      nosey.process ping, name
    end

    @runner.start
    c = KingKong::Test::ReadSocket.start('/tmp/king_kong_test.socket')
    c.send_data("READ\nQUIT\n")
    c.callback{|data|
      @data = data
    }
    ly{ @data }.test{|data| data =~ /max/ }
  end
end

describe KingKong::Runner::DSL::Pinger do
  # Lets kinda simulate this in our DSL
  def ping(name)
    KingKong::Runner::DSL::Pinger.new
  end

  it "should accept minutes" do
    config = ping(:google).every(3).minutes
    config.duration.should eql(3 * 60)
  end

  it "should accept seconds" do
    config = ping(:google).every(3).seconds
    config.duration.should eql(3)
  end

  it "should accept hours" do
    config = ping(:google).every(3).hours
    config.duration.should eql(3 * 60 * 60)
  end

  it "should accept block" do
    block = Proc.new {}
    config = ping(:twitter).every(1).second &block
    config.block.should eql(block)
  end

  context "pinger configuration" do
    before(:each) do
      @pinger = ping(:brad).every(2).hours.pinger
    end
    
    it "should have wait" do
      @pinger.wait.should eql(2 * KingKong::Runner::DSL::Pinger::Unit::Hour) # 2 hours
    end
  end
end