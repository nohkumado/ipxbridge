import 'package:args/args.dart';
import 'package:ipxbot/ipxbot.dart' as ipxbot;
import 'package:ipxbot/ipxbot.dart';

void main(List<String> arguments)
{
  var parser = ArgParser();
  parser.addOption('server', abbr: 's', defaultsTo: 'https://matrix.org');
  parser.addOption('user', abbr: 'u', defaultsTo: 'testbot');
  parser.addOption('passwd', abbr: 'p', defaultsTo: 'nothing');
  parser.addOption('room', abbr: 'r', defaultsTo: '#testchan');
  parser.addOption('roomid', abbr: 'i');
  parser.addOption('invite', abbr: 'c');
  parser.addOption('msg', abbr: 'm', defaultsTo: 'Hello!');
  var results = parser.parse(arguments);

  var  bridge = ipxbot.IpxMatrixBridge();
  //IpxBot bot = new IpxBot(results);
  print('Start of prog!');
  doWork(bridge, results);
  //String data = bot.capas();
  //print('capas: ${data}!');
}
 void doWork(IpxMatrixBridge  bridge, ArgResults results )
 async {
   String roomid =(results['roomid'].isNotEmpty)?results['roomid']:'';
   print("connecting to server ${results["server"]}");
   await bridge.connect(results['server']);
   print("logging in with  ${results["user"]} and ${results["passwd"]}");
   await bridge.login(user: results['user'], passwd: results['passwd']);
   if(roomid.isEmpty) {
     print(
         "trying to create room= ${results["room"]} and inviting ${results["invite"]}");
     roomid = await bridge.createRoom(results['room'], invites: results['invite']);
   }

   if(await bridge.joinRoom(roomid))
     {
       //print("login = ${log} ");
       print("trying to send  ${results["msg"]}!");
       await bridge.sendMsg(results['msg']);
     }
 }

 String capas(IpxMatrixBridge  bridge)
 {
   var data = bridge.capabilitites();
   return data;
 }