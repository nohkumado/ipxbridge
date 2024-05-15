import 'dart:io';

import 'package:args/args.dart';
import '../lib/ipxbot.dart';

void main(List<String> arguments)
{
  var parser = ArgParser();
  parser.addOption('server', abbr: 's', defaultsTo: 'https://matrix.org',help: 'The Matrix server to host the bot.');
  parser.addOption('user', abbr: 'u', defaultsTo: 'testbot',help: 'The username of the bot.');
  parser.addOption('passwd', abbr: 'p', defaultsTo: 'nothing',help: 'The password of the bot.');
  parser.addOption('room', abbr: 'r', defaultsTo: '#testchan',help: 'The default room the bot will join.');
  parser.addOption('roomid', abbr: 'i',help: 'The roomid of the bot room where it should stay.');
  parser.addOption('invite', abbr: 'e',help: 'users the bot should invite to the room, NIY');
  parser.addOption('msg', abbr: 'm', defaultsTo: 'Hello!', help: 'The message the bot will send upon joining the room.');
  parser.addOption('config', abbr: 'c', defaultsTo: './', help: 'The configuration directory for the bot');
  ArgResults results;
  try {
    results = parser.parse(arguments);
  }
  catch(e) {
    print(e);
    print('Example: dart bin/ipxbot.dart -u mybot -p use_a_good_passwd -r #botsroom:matrix.org -c @myself:matrix.org');
    print('Usage: ipxbot ${parser.usage}');
    exit(1);
  }

  var  bridge = IpxMatrixBridge()..greeting(results['msg'])
                                 ..configDir(results['config'])
    //..saveConfig()
    ..loadConfig();
  print('Start of prog!');
  doWork(bridge, results);
}
 void doWork(IpxMatrixBridge  bridge, ArgResults results )
 async {
   String roomid =(results['roomid'].isNotEmpty)?results['roomid']:'';
   print("connecting to server ${results["server"]}");
       bridge.connect(results['server'],user: results['user'], passwd: results['passwd'],roomid: roomid);
 }

