import 'package:matrix/matrix.dart';


class IpxMatrixBridge
{
  String token ="";

  String userid ="";
  int txnId = 1;
  String rid ="";
  late Client client;


  void connect(String server,{String user : 'toto', String passwd:'12345',String roomid:''})
  {
    client = Client("IpxBot");
    client.onLoginStateChanged.stream
	.listen((bool loginState)
	    { 
        print("LoginState: ${loginState.toString()}");
    });

    client.onEvent.stream.listen((EventUpdate eventUpdate){ 
        print("New event update!");
    });

    client.onRoomUpdate.stream.listen((RoomUpdate eventUpdate){ 
        print("New room update!");
    });

    client.checkHomeserver(Uri.parse(server)).then(()=> client.login(
	  identifier: AuthenticationUserIdentifier(user: user),
	    password: passwd,
    ).then(()=> client.getRoomById('your_room_id').sendTextEvent('Hello world'))
	);
    ;
    ;

  }
//   Future<String> createRoom(String name, {desc = "a Room", topic: "testing", invites: ""})
//   async {
//     api.accessToken = token;
//     print("api access token? ${api.accessToken}");
//     /*
//       Future<String> createRoom({
//         Visibility visibility,
//         String roomAliasName,
//         String name,
//         String topic,
//         List<String> invite,
//         List<Map<String, dynamic>> invite3pid,
//         String roomVersion,
//         Map<String, dynamic> creationContent,
//         List<Map<String, dynamic>> initialState,
//         CreateRoomPreset preset,
//         bool isDirect,
//         Map<String, dynamic> powerLevelContentOverride,
//       }) async {
//       */
//     rid = await api.createRoom( roomAliasName: name,  name: desc, topic: topic,invite: [invites]);
//     //String rid = await api.joinRoomOrAlias( roomAlias);
//     print("joined room $rid!");
//     return rid;
//   }
//   Future<bool> joinRoom(String roomid)
//   async {
//     api.accessToken = token;
//     print("api access token? ${api.accessToken}");
//     try {
//       rid = await api.joinRoom(roomid);
//     }
//     catch(e) {
//       print("unkown error joining roominfo : ${e.errcode}= ${e.errorMessage}");
//       return false;
//     }
//     //String rid = await api.joinRoomOrAlias( roomAlias);
//     print("joined room $rid!");
//     return true;
//   }
//   void sendMsg(String msg)
//   async {
//     Map<String,dynamic> content = {
//       "msgtype": "m.text",
//       "body": msg
//     };
//
//     if(rid != null) {
//       String eventid = await api.sendMessage(
//           rid, "m.room.message", "$txnId", content);
//       print("send message $eventid!");
//     }
//     else print("not connected.... can't send msg");
//   }
}
