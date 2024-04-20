import 'ipxbot.dart';
import 'package:tuple/tuple.dart';

import 'ipxentity.dart';
import 'ipx.dart';
import 'req_res.dart';

class IpxChatbot {
  final Map<String, List<String>> _userHistory = {}; // Stores user chat history
  final IpxMap ipx; // Optional Ipx interface for interacting with Ipx
  final String botName;
  final IpxMatrixBridge bridge; //reference to the bridge itself (for commands like load and save)

  IpxChatbot({required this.ipx, required this.botName, required this.bridge});

  // Function to handle a user message
  Future<ReqRes> handleMessage(String sender, String message, {String type = 'm.text'}) async {
    // Update user history
     _userHistory.putIfAbsent(sender, () => []);
     _userHistory[sender]?.add(message);
     if(type == 'm.emote') return handleEmote(sender, message);
     print('CB:Need to process ${type == 'm.text' ? 'msg' : type == 'm.emote' ?'emote':'$type'}: ${sender}:$message');
    Tuple2<Ipx,IpxEntity>? res = ipx.find(message.trim());
     if(res == null) res = ipx.find(message.toLowerCase().trim());
    if(res != null)
    {
      print('CB:found: ${res.item2}');
      String mesg = await res.item1.schalte( sender: sender, schalter:res.item2 );
      print('CB:response: ${mesg}');
      return ReqRes( msg: mesg, status: true ); //return mesg;
    }


    // Simple response logic based on keywords and history
    String response = "";
     switch(message)
     {
       case 'hello': response = "hello ${sender}"; break;
       case '?':
       case 'help': response = "help: \n  hello: greet user\n  ?|help: issue this help\n  save: save the configuration\n ${ipx.compileIpxCmds()}}"; break;
       case 'save': bridge.saveConfig(); break;
       default: print('CB:Need to process msg: ${message} from ${sender}');
     }
     if(response.isNotEmpty) return ReqRes( msg: response, status: true );

    if (message.toLowerCase().contains("how") &&
        message.toLowerCase().contains("you")) {
      response = "I'm doing well, thanks for asking!";
    }
    else if (_userHistory[sender]!.length > 1)
    {
      // Access previous message from the user
      final previousMessage = _userHistory[sender]!.last;
      if (previousMessage.toLowerCase().contains("what") &&
          previousMessage.toLowerCase().contains("weather")) {
        response = "Unfortunately, I don't have real-time weather information yet.";
      }  else {
        response = "You previously mentioned $previousMessage. Can you tell me more about that?";
      }
    }
    else response = "gnii?";

     return ReqRes( msg: response, status: true ); //return mesg;
  }

  Future<ReqRes> handleEmote(String sender, String message)
  async{
    if(message.contains(botName))
    {
    //ok it concerns me....
    print('CB:Need to process emote: ${sender}:$message');
    return ReqRes( msg: 'Wuff?', status: true, type: 'emote' ); //return mesg;
    }

    return ReqRes( msg: 'hmm', status: true ); //return mesg;
  }
}
