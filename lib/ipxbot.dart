import 'package:matrix_api_lite/matrix_api_lite.dart';
import 'package:matrix_api_lite/src/matrix_api.dart';


class IpxMatrixBridge
{
  MatrixApi api;// = MatrixApi(homeserver: Uri.parse('https://matrix.org'));
  LoginResponse loginData;
  String token;

  String userid;
  int txnId = 1;
  String rid;



  Future<Map> getCapabilitites(api) async => await api.requestServerCapabilities();
  login({passwd, user})
  async {
    loginData = await api.login(user: user, password: passwd);
    if(loginData != null)
    {
      token = loginData.accessToken;
      userid = loginData.userId;
      print("logged into server! token= $token");
      api.accessToken = token;
      //String rid = await api.joinRoomOrAlias( roomId);


    }
    else print("failed to login into server");
    //if(loginData != null) print("fetched ${loginData.toJson()}");
    print("fetched ${loginData}");
    //else print("got null as  ${loginData}");
  }

  String capabilitites() {
    final capabilities = getCapabilitites(api);
    return capabilities.toString();
  }

  void connect(String server)
  {
    api = MatrixApi(homeserver: Uri.parse(server));
  }
  void joinRoom(String name, {desc = "a Room", topic: "testing", invites: ""})
  async {
    api.accessToken = token;
    print("api access token? ${api.accessToken}");
    /*
      Future<String> createRoom({
        Visibility visibility,
        String roomAliasName,
        String name,
        String topic,
        List<String> invite,
        List<Map<String, dynamic>> invite3pid,
        String roomVersion,
        Map<String, dynamic> creationContent,
        List<Map<String, dynamic>> initialState,
        CreateRoomPreset preset,
        bool isDirect,
        Map<String, dynamic> powerLevelContentOverride,
      }) async {
      */
    rid = await api.createRoom( roomAliasName: name,  name: desc, topic: topic,invite: [invites]);
    //String rid = await api.joinRoomOrAlias( roomAlias);
    print("joined room $rid!");
  }
  void sendMsg(String msg)
  async {
    Map<String,dynamic> content = {
      "msgtype": "m.text",
      "body": msg
    };

    if(rid != null) {
      String eventid = await api.sendMessage(
          rid, "m.room.message", "$txnId", content);
      print("send message $eventid!");
    }
    else print("not connected.... can't send msg");
  }
}