# KingKong

                ,.-" "-.,
               /   ===   \
              /  =======  \
           __|  (o)   (0)  |__      
          / _|    .---.    |_ \         
         | /.----/ O O \----.\ |       
          \/     |     |     \/        
          |                   |            
          |                   |       Full stack health checks for your networked apps!
          |                   |         (Kinda like Pingdom, but way deeper and free)
          _\   -.,_____,.-   /_         
      ,.-"  "-.,_________,.-"  "-.,
     /          |       |          \  
    |           l.     .l           | 
    |            |     |            |
    l.           |     |           .l             
     |           l.   .l           | \,     
     l.           |   |           .l   \,    
      |           |   |           |      \,  
      l.          |   |          .l        |
       |          |   |          |         |
       |          |---|          |         |
       |          |   |          |         |
       /"-.,__,.-"\   /"-.,__,.-"\"-.,_,.-"\
      |            \ /            |         |
      |             |             |         |
       \__|__|__|__/ \__|__|__|__/ \_|__|__/

KingKong makes it easy to build full-stack ping-pong health checks so you can keep an eye on crucial input/outputs and make sure things stay nice and fast. You might need this to check and graph out the response time on your website, Twitter application, SMS gateway, or whatever else you'd connect to a network.


## Getting Started

Install the KingKong gem.

    gem install kingkong

Then implement your ping checks in Ruby.

    require 'kingkong'
    require 'em-http-request'

    KingKong.start {
      socket '/tmp/king_kong.socket' # Check this socket with Munin and make a graph!

      ping(:google).every(3).seconds do |ping|
        ping.start
        google = EventMachine::HttpRequest.new('http://google.com/').get
        google.callback { ping.stop }
        google.errback  { ping.fail }
      end

      ping(:twitter).every(10).seconds do |ping|
        # Wire up your own thing in here that tweets
        # .. and when you pick that up, end the pong!
      end

      ping(:verizon).every(2).seconds do |ping|
        # Hook your machine up to a GSM serial modem
        # and perform regular SMS pings against your app.
      end
    }

Save the file and run it! You'll see some crazy log output right now, but eventually its going to be prettier.

You can see the stat aggregates of the pings by looking into the socket:

    watch cat /tmp/king_kong.socket

If you don't understand EventMachine, you might have a little trouble getting this stuff working. Eventually I'd like to hook up Em::Syncrony and a nicer DSL for common tasks, like HTTP checks, to keep things simple.

## Using KingKong with Munin graphs

I'm working on this!