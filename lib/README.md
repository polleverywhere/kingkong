# KingKong

                ,.-" "-.,
               /   ===   \
              /  =======  \
           __|  (o)   (0)  |__      
          / _|    .---.    |_ \         
         | /.----/ O O \----.\ |       
          \/     |     |     \/        
          |                   |            
          |                   |           KingKong gets what KingKong wants!
          |                   |          
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

KingKong makes it easy to build full-stack ping-pong checks. You might need this to check and graph out the response time on your website, Twitter application, SMS gateway, or whatever else you'd connect to a network.

When its done, it will look something like this:

    KingKing.monitor {
      ping.every(3).seconds :google do |ping|
        google = http('http://www.google.com/').get

        ping.errback {
          # Email the admin! Google is down!
        }

        ping.start_time           # Start the clock!
        google.callback {        # This triggers the request
          ping.end_time           # And this stops the clock!
        }
      end

      ping.every(10).seconds :twitter do |ping|
        # Wire up your own thing in here that tweets
        # .. and when you pick that up, end the pong!
      end
    }.start

and its going to aggregate stats so you can plug it into munin and get all sorts of graphing goodness.

Stay tuned, I'm still working out the ping DSL and reporting infrastructure!