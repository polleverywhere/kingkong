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

When its done, it will look something like this:
    
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

and its going to aggregate stats so you can plug it into munin and get all sorts of graphing goodness.

Stay tuned, I'm still working out the ping DSL and reporting infrastructure!