import 'package:matrix_api_lite/matrix_api_lite.dart';
import 'package:matrix_api_lite/src/matrix_api.dart';

final String konto = "chaletbot";
final String pass = "ur3jHtaCiSUQbfS";
final String  roomAlias = "#bboettsbotroom:matrix.org";
//final String  roomAlias = "@bboett:matrix.org";
final String  roomId = "!OXOtvaYQZByMfTUVsg";

int calculate()
{
  return 6 * 7;
}

class IpxMatrixBridge
{
  final api = MatrixApi(homeserver: Uri.parse('https://matrix.org'));
  LoginResponse loginData;
  String token;

  String userid;
  int txnId = 1;



  String capabilitites() {
    final capabilities = getCapabilitites(api);
    return capabilities.toString();
  }
  Future<Map> getCapabilitites(api) async => await api.requestServerCapabilities();
  login()
  async {
    loginData = await api.login(user: konto, password: pass);
    if(loginData != null)
    {
      token = loginData.accessToken;
      userid = loginData.userId;
      print("logged into server! token= $token");
      api.accessToken = token;
      //String rid = await api.joinRoomOrAlias( roomId);

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
      String rid = await api.createRoom( roomAliasName: roomAlias,  name: "a Room", topic: "testing",invite: ["@bboett:matrix.org"]);
      //String rid = await api.joinRoomOrAlias( roomAlias);
      print("joined room $rid!");
      Map<String,dynamic> content = {
        "msgtype": "m.text",
        "body": "hello"
      };

      String eventid = await api.sendMessage(roomId, "m.room.message", "$txnId", content);
      print("send message $eventid!");

    }
    else print("failed to login into server");
    //if(loginData != null) print("fetched ${loginData.toJson()}");
    print("fetched ${loginData}");
    //else print("got null as  ${loginData}");
  }
}