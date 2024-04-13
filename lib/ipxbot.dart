import 'dart:convert';
import 'dart:io';

import 'package:matrix/matrix.dart';
import 'ipx.dart';
import 'package:http/http.dart' as http;

import 'ipx_chatbot.dart';
import 'ipxentity.dart';
import 'req_res.dart';

class IpxMatrixBridge
{
  String token ='';
// in: 1 sonnette dojo, 3 capteur eua pluie, 5 sonnette privee
  //out:  4 staubsauger, 5 sonnette privee, 6 überlauf regen, 7 garage
  //trigger garage: ex. Set071p
  //GetIn7
  //retrieve state http://domus.lan/api/xdevices.json?cmd=10
  //Pilotage d'un Relais en M2M<br>
  //Sortie 5 : <a href=http://192.168.0.9/M2M/M2M.php?commande=Set050>off</a>
  //&nbsp;<a href=http://192.168.0.9/M2M/M2M.php?commande=Set051>on</a>



  String userid;
  String username;
  int txnId;
  String rid;
  late Client client;
  Room? myRoom ;
  List<String> allowedusers;
  int m2mport;
  String m2mhost;

  final DateTime activationDate = DateTime.now() ;

  IpxMap ipxes = IpxMap(map:{});

  String greetMsg = 'Hello World!';

  String configRep = "./";
  late final IpxChatbot chatter;

  List<IpxEntity> lastChanges = [];
  DateTime lastEvent = DateTime.now() ;

  int changeTmout = 5;//in seconds

  IpxMatrixBridge({this.userid = "", this.username = "", this.txnId = 1, this.rid = '', this.allowedusers = const ['@bboett:matrix.org', '@bboett:nohkumado.eu','@sophie_boettcher:matrix.org','@nathan_boettcher:matrix.org', '@boettcher_manuela:matrix.org','@arthur_boettcher:matrix.org', '@wibo:matrix.org'], this.m2mport = 9870, this.m2mhost= 'tcp://domus.lan/'} ) {
    //to be later exported to a json encoded file.... TODO!
    ipxes['domus'] =Ipx('domus', port: 9870, host: 'domus.lan')
      ..define(IpxInput(n:0,name:'sonnette dojo'))
      ..define(IpxInput(n:2,name:'reservoir trop plein'))
      ..define(IpxInput(n:4,name:'sonnette privee'))
      ..define(IpxOutput(n:0,name:'sonnette dojo'))
      ..define(IpxOutput(n:2,name:'gache porte'))
      ..define(IpxOutput(n:3,name:'aspirateur', cmd: 'aspi'))
      ..define(IpxOutput(n:4,name:'actionneur sonnette privee'))
      ..define(IpxOutput(n:5,name:'vidange reservoir', cmd: 'vidange'))
      ..define(IpxOutput(n:6,name:'porte garage', type: switchtypes.button, cmd: 'garage'));
    chatter = IpxChatbot(ipx: ipxes, botName: username);
  }


  Future<void>
  connect(String server,{String user = 'toto', String passwd ='12345',String roomid =''})
  async
  {
    print("entering connect");
    username = user;
    client = Client('IpxBot');
    client.onLoginStateChanged.stream.listen((event) {print('LoginState: $event'); });

    client.onEvent.stream.listen((EventUpdate r_event){
      //print("incoming event of type: '${r_event.type}' ${r_event.type.runtimeType}");
      if(r_event.type == EventUpdateType.timeline && r_event.content['type'] == "m.room.message") processMsg(r_event.content);
      else if(r_event.type == EventUpdateType.inviteState) processInvite(r_event);
      else print('New event update! t:${r_event.type} c:${r_event.content}');
    });
    client.onRoomState.stream.listen((Event eventUpdate)
    {
      //print("Room state change: ${eventUpdate.type} ${eventUpdate.content}");
      //Room state change: m.room.member {is_direct: true, membership: invite, displayname: chaletbot}
      if(eventUpdate.type == 'm.room.member' &&
          eventUpdate.content['is_direct'] =='true' &&
          eventUpdate.content['membership'] == 'invite' &&
          eventUpdate.content['displayname'] == username)
      {
        processDirectInvite(eventUpdate);
      }
    });

    //client.onRoomUpdate.stream.listen((RoomUpdate eventUpdate){
    //    print("New room update!");
    //});
    client.checkHomeserver(Uri.parse(server)).then(
            (value) => client.login(
          LoginType.mLoginPassword,
          identifier: AuthenticationUserIdentifier(user: user),
          password: passwd,
        ).then((value) {
          myRoom = client.getRoomById(roomid);
          post2Room(greetMsg);
        }

        ));
    //Start http server
    var http_server = await HttpServer.bind(InternetAddress.anyIPv4, 8123);

    print('Listening on ${http_server.address}:${http_server.port}');

    //Debug test remove before prod
    triggerOutput(sender: 'me', schalter:8.toString());
    // Listen for incoming requests
    await for (var request in http_server)
    {
      // Handle each request
      handleRequest(request);
    }
  }

  Future<void> post2Room(String s, {String type = 'text'}) async {
    if(myRoom != null) {
      if(type == 'emote') await myRoom!.sendTextEvent(s, msgtype: 'm.emote');
      else await myRoom!.sendTextEvent(s);
    } else print("No room :( : $s");
  }

  Future<void> processMsg(Map<String, dynamic> content)
  async {
    String sender = content['sender'];
    String message = content['content']['body'];
    String msgType = content['content']['msgtype'];
    //int tmstamp = content['unsigned']?['age']??0;
    int tmstamp = content['origin_server_ts']??0;
    DateTime msgDate = DateTime.fromMillisecondsSinceEpoch(tmstamp);
    if(msgDate.isBefore(activationDate)) return; //forget old messages

    if(allowedusers.contains(sender))
    {
      // Create a mutable copy of the query parameters
      print('PM:Need to process msg: ${content}');
      ReqRes res = await chatter.handleMessage(sender, message, type: msgType);
     if(res.status) {
       print("PM... chatty returned something ${res.msg}");
       post2Room("${res.msg}", type: res.type);
       return;
     }
      print("PM... no luck with chatty going legacy");
      //print("##### processing $message");
      //check if a configured command applies
      //Tuple2<Ipx,IpxEntity>? res = ipxes.find(message);
      //if(res != null)
      //{
      //  String mesg = await res.item1.schalte( sender: sender, schalter:res.item2 );
      //  if(mesg.isNotEmpty) post2Room(mesg);
      //  return;
      //}
      //if(pG.item2 >=0)
      switch(message)
      {
        case 'hello': post2Room("hello ${sender}"); break;
        case '?':
        case 'help': post2Room("help: ${ipxes.compileIpxCmds()}}"); break;
        case 'garage':
          print("PM... found garage");
          triggerOutput(sender: sender, schalter: 'porte garage');
          break;
        case 'aspi':
          print("PM... found aspi");
          post2Room("Hai ${sender}! starte Staubsauger!");
          toggleOutput(sender: sender, schalter:'aspirateur');
          break;
        default: print('DC:Need to process msg: ${message} from ${sender}');
      }
    }
    else if(sender.startsWith("@$username:") ){}//ignore it
    else print("[$username]ignoring user ${sender} with message ${message}");
  }

  Future<void> handleRequest(HttpRequest request) async {
    // print("got a request for ${request.requestedUri}");

    if (request.method == 'GET') {
      // Handle GET request
      Map<String,String> args = request.uri.queryParameters;
      if (args.isNotEmpty)
      {
        // Assuming the notification data is passed as query parameters
        //print('Received[GET] push notification: $args');
        if(ipxes.containsKey(args["id"]??"")) {
          DateTime msgDate = DateTime.now();
          if(msgDate.isAfter(lastEvent.add(Duration(seconds: changeTmout)))) lastChanges.clear(); //forget old messages

          Ipx actIpx = ipxes[args["id"]!]!;
          List<IpxEntity> changes = actIpx.statusChange(args);

          if(changes.isNotEmpty)
          {
            StringBuffer result = StringBuffer();
            if(lastChanges.isNotEmpty)
            {
              for(IpxEntity e in changes) {
                if(!lastChanges.contains(e)) {
                  result.write(e.name + " ");
                }
              }
            }
            else
            {
              for(IpxEntity e in changes) {
                result.write(e.name + ",");
              }
            }
            lastChanges = changes;
            if(result.isNotEmpty)
            {
              post2Room("Status changes: $result");

            }
          }
        }  else
          print("ehm... unknown ipx: '${args['id']}'");
      }else
        print("oy... args is empty??? '$args'");
      request.response
        ..statusCode = HttpStatus.ok
        ..write('Notification received')
        ..close();
    }
    else if (request.method == 'POST') {
      // Handle POST request
      //var content = request.transform(Utf8Decoder()).join() ;
      //var queryParams = Uri(query: content).queryParameters;
      String reply = await utf8.decoder.bind(request).join();



      print('Received[POST] push notification: $reply');

      // request.transform(Utf8Decoder()).listen((body) {
      //   // Handle the body of the request
      //   print('Received push notification: $body');

      //   // Here you can process the received notification
      //   // and perform actions based on it for your domotic needs
      // });
      request.response
        ..statusCode = HttpStatus.ok
        ..write('Notification received')
        ..close();
    } else {
      // Handle other HTTP methods
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write('Unsupported request method')
        ..close();
    }
  }
  /// toggle the switch of any output
  Future<void> triggerOutput({required String sender, required String schalter})
  async {
    // Craft the message for the room
    post2Room("Hai ${sender}! betätige Schalter $schalter!");
    final Ipx actIps = ipxes["domus"]!;
    Uri url=Uri(scheme: 'http', host: actIps.host, path: 'leds.cgi');
    IpxEntity? pG = actIps.find(schalter);
    if(pG != null) {
      // Create a mutable copy of the query parameters map
      Map<String, String> queryParameters = Map.from(url.queryParameters);
      queryParameters['led'] = pG.n.toString();

      // Assign the modified query parameters back to the url
      url = url.replace(queryParameters: queryParameters);

      //url.queryParameters['led'] = pG.item2.toString();
      // Send the URI request using an appropriate HTTP client library
      final response = await http.get(url); // Use http.get for GET requests

      if (response.statusCode == 200) {
        post2Room("$schalter toggle request sent successfully."); // Indicate success
      } else {
        post2Room("Error sending $schalter request: ${response.statusCode}");
      }
    }
    else print("no such entry: '$schalter'");

  }
 /// open our garage
  /// 'aspirateur'
  Future<void> toggleOutput({required String sender, required String schalter})
  async {
    // Craft the message for the room
    post2Room("Hai ${sender}! schalte $schalter!");
    Ipx actIps = ipxes["domus"]!;
    //that ons is to set the type of switch
    //final Uri url=Uri(scheme: 'http', host: actIps.host, path: 'protect/assignio/assign1.htm');
    final Uri url=Uri(scheme: 'http', host: actIps.host, path: 'preset.htm');
    IpxEntity? pG = actIps.find(schalter);
    if(pG != null) {

      url.queryParameters['set${(pG.n+1)}'] = (!actIps.getState(entity:pG)).toString();
      //keep for further reference API info:
      //url.queryParameters('relayname', 'porte garage');
      // Set delay parameters (assuming these are supported by the API)
      //url.queryParameters['delayon'] = 0.toString();
      //url.queryParameters['delayoff'] = 5.toString();
      // Send the URI request using an appropriate HTTP client library
      // (assuming post2Room doesn't handle this functionality)
      final response = await http.get(url); // Use http.get for GET requests

      if (response.statusCode == 200) {
        post2Room("'$schalter' toggle request sent successfully."); // Indicate success
      } else {
        post2Room("Error sending toggle '$schalter' request: ${response.statusCode}");
      }
    }
    else post2Room("no such entry: '$schalter'");

  }


  greeting(String? altGreet)
  {
    greetMsg = altGreet??greetMsg;
  }

  configDir(String? altConf)
  {
    configRep = altConf??configRep;
  }

  void loadConfig() {
    final configFile = File('$configRep/config.json');

    // Check if the file exists
    if (configFile.existsSync()) {
      try {
        final config = configFile.readAsStringSync();
        ipxes = IpxMap.fromJson(config);
      } catch (e) {
        stderr.writeln('[Ipxbot] Error parsing config file: $e');
        // Handle parsing errors (optional: consider default values or exit)
      }
    } else {
      stderr.writeln('[Ipxbot] Config file not found: ${configFile.path} continuing with defaults');
      //stderr.writeln('[Ipxbot] writing one with default');
      // Handle missing file (optional: create a default config, exit)
    }
  }
  void saveConfig() {
    // Ensure trailing path separator
    if (!configRep.endsWith(Platform.pathSeparator)) {
      configRep += Platform.pathSeparator;
    }
    if(configRep.startsWith('~')) configRep = '${Platform.environment['HOME']}${configRep.substring(1)}';


    // Create the directory if it doesn't exist
    final dir = Directory(configRep);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true); // Create recursively if needed
    }

    final configFile = File(configRep + 'config.json');
    final configJson = ipxes.toJson(); // Convert IpxMap to JSON string, TODO add changeTmout

    try {
      print("writing $configJson\nto $configFile");
      configFile.writeAsStringSync(configJson);
      print('Config file saved successfully to $configFile.'); // Inform success
    } catch (e) {
      // Handle file system errors (optional: retry or report)
      stderr.writeln('Error saving config file: $e');
    }
  }

  void processInvite(EventUpdate r_event)
  {
    print("Imnvite:: ${r_event.type},${r_event.content},${r_event.roomID}");

    /*
    EU c:{type: m.room.join_rules, content: {join_rule: invite}, sender: @bboett:nohkumado.eu, state_key: }
Room state change: m.room.create {room_version: 10, creator: @bboett:nohkumado.eu}
EU t:EventUpdateType.inviteState c:{type: m.room.create, content: {room_version: 10, creator: @bboett:nohkumado.eu}, sender: @bboett:nohkumado.eu, state_key: }
Room state change: m.room.encryption {algorithm: m.megolm.v1.aes-sha2}
EU t:EventUpdateType.inviteState c:{type: m.room.encryption, content: {algorithm: m.megolm.v1.aes-sha2}, sender: @bboett:nohkumado.eu, state_key: }
Room state change: m.room.member {membership: join, displayname: bboett, avatar_url: mxc://nohkumado.eu/OypILvTTJPelppdPGPEIvhEl}
EU t:EventUpdateType.inviteState c:{type: m.room.member, content: {membership: join, displayname: bboett, avatar_url: mxc://nohkumado.eu/OypILvTTJPelppdPGPEIvhEl}, sender: @bboett:nohkumado.eu, state_key: @bboett:nohkumado.eu}
Room state change: m.room.member {is_direct: true, membership: invite, displayname: chaletbot}
EU t:EventUpdateType.inviteState
   c:{type: m.room.member, content: {is_direct: true, membership: invite, d
        isplayname: chaletbot}, sender: @bboett:nohkumado.eu, state_key: @chaletbot:nohkumado.eu}
*/

  }

  void processDirectInvite(Event eventUpdate)
  {
    print("got a direct invite to $eventUpdate ${eventUpdate.type},${eventUpdate.text},${eventUpdate.body},${eventUpdate.infoMap},${eventUpdate.messageType},${eventUpdate.originalSource},${eventUpdate.room},${eventUpdate.parsedForwardedRoomKeyContent}");
  }

}
