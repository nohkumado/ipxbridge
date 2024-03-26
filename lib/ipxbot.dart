import 'dart:convert';
import 'dart:io';

import 'package:matrix/matrix.dart';

import 'ipx.dart';


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

  Map<String,Ipx> ipxes = {
    'domus' : Ipx('domus', port: 9870, host: 'domus.lan')
      ..input(n:1,name:'sonnette dojo')
      ..input(n:3,name:'reservoir trop plein')
      ..input(n:5,name:'sonnette privee')
      ..output(n:1,name:'sonnette dojo')
      ..output(n:3,name:'gache porte')
      ..output(n:4,name:'aspirateur')
      ..output(n:5,name:'actionneur sonnette privee')
      ..output(n:6,name:'vidange réservoir ')
      ..output(n:7,name:'porte garage')
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
        case 'garage': post2Room("Hai ${sender}! öffne Garagentor!"); break;
        case 'aspi': post2Room("Hai ${sender}! starte Staubsauger!"); break;
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
}
