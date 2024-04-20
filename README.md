# IPX - Matrix bridge

a try for a bridge handling on one side, the incoming stuff of an ipx home automation system 
and informing a matrix channel, and on the other side, 
accept commands on that channel to pass to the ipx.


run from bin/ipxbot.dart either in android studio or from command line with dart run
needs command line arguments (either edit studio configuration or on cmd line)

like 

```
dart run bin/ipxbot -u mybot -p use\_a\_good\_passwd -r #botsroom:matrix.org -i !gWOtdaUZZByMfTOVam:matrix.org -s "https://matrix.org" -m "Je suis là" -c ~/config/ipxbot/
```
