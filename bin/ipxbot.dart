import 'package:ipxbot/ipxbot.dart' as ipxbot;
import 'package:ipxbot/ipxbot.dart';
import 'package:matrix_api_lite/matrix_api_lite.dart';

void main(List<String> arguments)
{
  IpxBot bot = new IpxBot();
  print('Hello world: ${ipxbot.calculate()}!');
  //String data = bot.capas();
  //print('capas: ${data}!');

}
class IpxBot
{
 IpxMatrixBridge  bridge = new ipxbot.IpxMatrixBridge();
 IpxBot()
 {
   bridge.login();
   //print("login = ${log} ");

 }

 String capas()
 {

   String data = bridge.capabilitites();
   return data;
 }

}