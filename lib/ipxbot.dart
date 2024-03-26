import 'dart:convert';
import 'dart:io';

import 'package:matrix/matrix.dart';
import 'package:tuple/tuple.dart';

import 'ipx.dart';
import 'package:http/http.dart' as http;

import 'ipxentity.dart';

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



  String userid ='';
  String username ='';
  int txnId = 1;
  String rid ='';
  late Client client;
  Room? myRoom ;
  List<String> allowedusers = ['@bboett:matrix.org', '@bboett:nohkumado.eu','@sophie_boettcher:matrix.org','@nathan_boettcher:matrix.org', '@boettcher_manuela:matrix.org','@arthur_boettcher:matrix.org', '@wibo:matrix.org'];
  int m2mport = 9870;
  String m2mhost = 'tcp://domus.lan/';

  final DateTime activationDate = DateTime.now() ;

  //to be later exported to a json encoded file.... TODO!
  Map<String,Ipx> ipxes = {
    'domus' : Ipx('domus', port: 9870, host: 'domus.lan')
      ..define(IpxInput(n:0,name:'sonnette dojo'))
      ..define(IpxInput(n:2,name:'reservoir trop plein'))
      ..define(IpxInput(n:4,name:'sonnette privee'))
      ..define(IpxOutput(n:0,name:'sonnette dojo'))
      ..define(IpxOutput(n:2,name:'gache porte'))
      ..define(IpxOutput(n:3,name:'aspirateur'))
      ..define(IpxOutput(n:4,name:'actionneur sonnette privee'))
      ..define(IpxOutput(n:5,name:'vidange réservoir '))
      ..define(IpxOutput(n:6,name:'porte garage', type: switchtypes.button))
    ,
  };


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
      //else print('New event update! t:${r_event.type} c:${r_event.content}');
    });
    client.onRoomState.stream.listen((Event eventUpdate)
    {
      //print("Room state change: ${eventUpdate.type} ${eventUpdate.content}");
    });

    //client.onRoomUpdate.stream.listen((RoomUpdate eventUpdate){
    //    print("New room update!");
    //});
    //client.checkHomeserver(Uri.parse(server)).then(
    //        (value) => client.login(
    //      LoginType.mLoginPassword,
    //      identifier: AuthenticationUserIdentifier(user: user),
    //      password: passwd,
    //    ).then((value) {
    //      myRoom = client.getRoomById(roomid);
    //      //if(myRoom != null) await myRoom!.sendTextEvent('Hello world');
    //      post2Room('Hello world');
    //    }

    //    ));
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

  Future<void> post2Room(String s) async {
    if(myRoom != null) await myRoom!.sendTextEvent(s);
    else print("No room :( : $s");
  }

  void processMsg(Map<String, dynamic> content)
  {
    String sender = content['sender'];
    String message = content['content']['body'];
    print("debug: ${content['unsigned']}");
    //int tmstamp = content['unsigned']?['age']??0;
    int tmstamp = content['origin_server_ts']??0;
    DateTime msgDate = DateTime.fromMillisecondsSinceEpoch(tmstamp);
    if(msgDate.isBefore(activationDate)) return; //forget old messages
    print('Need to process msg: ${content}');
    if(allowedusers.contains(sender))
    {
      print("##### processing $message");
      switch(message)
      {
        case 'hello': post2Room("hello ${sender}"); break;
        case 'garage':
          triggerOutput(sender: sender, schalter: 'porte garage');
          break;
        case 'aspi':
          post2Room("Hai ${sender}! starte Staubsauger!");
          toggleOutput(sender: sender, schalter:'aspirateur');
          break;
        default: print('Need to process msg: ${message} from ${sender}');
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
        if(ipxes.containsKey(args["id"])) {
          Ipx actIpx = ipxes[args["id"]]!;
          List<String> changes = actIpx.statusChange(args);
          post2Room("Status changes received: $changes");
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
  /// toogle the switch of any output
  Future<void> triggerOutput({required String sender, required String schalter})
  async {
    // Craft the message for the room
    post2Room("Hai ${sender}! betätige Schalter $schalter!");
    final Ipx actIps = ipxes["domus"]!;
    Uri url=Uri(scheme: 'http', host: actIps.host, path: 'leds.cgi');
    Tuple2<String,int> pG = actIps.find(schalter);
    if(pG.item2 >=0) {
      // Create a mutable copy of the query parameters map
      Map<String, String> queryParameters = Map.from(url.queryParameters);
      queryParameters['led'] = pG.item2.toString();

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
    Tuple2<String,int> pG = actIps.find('aspirateur');
    if(pG.item2 >=0) {

      url.queryParameters['set${(pG.item2+1)}'] = (!actIps.getState(pG.item1,pG.item2)).toString();
      //keep for further reference API info:
      //url.queryParameters('relayname', 'porte garage');
      // Set delay parameters (assuming these are supported by the API)
      //url.queryParameters['delayon'] = 0.toString();
      //url.queryParameters['delayoff'] = 5.toString();
      // Send the URI request using an appropriate HTTP client library
      // (assuming post2Room doesn't handle this functionality)
      final response = await http.get(url); // Use http.get for GET requests

      if (response.statusCode == 200) {
        post2Room("Garage door toggle request sent successfully."); // Indicate success
      } else {
        post2Room("Error sending garage door toggle request: ${response.statusCode}");
      }
    }
    else post2Room("no such entry: 'porte garage'");

  }
}
