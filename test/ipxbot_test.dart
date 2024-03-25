import 'package:ipxbot/ipxbot.dart';
import 'package:test/test.dart';

void main() {
    var results = {
    'server': 'https://matrix.org',
      'user':'chaletbot',
      'passwd' :'ur3jHtaCiSUQbfS',
    'room': '#bboettsroom:matrix.org',
    'invite':'@bboett:matrix.org',
    'roomid': '!OXOtvaYQZByMfTUVsg:matrix.org'
  };
    var  bridge = IpxMatrixBridge();
  test('calculate', ()
  {
    String roomid =results['roomid']??'';
    print("connecting to server ${results["server"]}");
    bridge.connect(results['server']??'https://matrix.org',user : results['user']??'toto', passwd : results['passwd']??'12345',roomid : results['room']??'botroom' );
    print("logging in with  ${results["user"]} and ${results["passwd"]}");
    //if(roomid.isEmpty) {
    //  print(
    //      "trying to create room= ${results["room"]} and inviting ${results["invite"]}");
    //  roomid = bridge.createRoom(results['room'], invites: results['invite']) as String;
    //}

    //if(bridge.joinRoom(roomid) != null)
    //{
    ////print("login = ${log} ");
    //print("trying to send  ${results["msg"]}!");
    //bridge.sendMsg(results['msg']);
    //}
  });
}
