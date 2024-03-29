import 'dart:convert';

import 'package:ipxbot/ipx.dart';
import 'package:ipxbot/ipxbot.dart';
import 'package:ipxbot/ipxentity.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

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
  test('matrix test', ()
  {
    String roomid =results['roomid']??'';
    //print("connecting to server ${results["server"]}");
    //bridge.connect(results['server']??'https://matrix.org',user : results['user']??'toto', passwd : results['passwd']??'12345',roomid : results['room']??'botroom' );
    //print("logging in with  ${results["user"]} and ${results["passwd"]}");

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
    group('IpxEntity Tests', () {

      test('IpxInput subclass creation', () {
        final input = IpxInput(name: 'Input 1', n: 2);
        expect(input.type, ipxtypes.input);
        expect(input.value, false);
        expect(input.name, 'Input 1');
        expect(input.n, 2);
      });

      test('IpxOutput subclass creation', () {
        final output = IpxOutput(name: 'Output A', n: 5, type: switchtypes.button);
        expect(output.type, ipxtypes.output);
        expect(output.behavior, switchtypes.button);
        expect(output.value, false);
        expect(output.name, 'Output A');
        expect(output.n, 5);

        final toggleOutput = IpxOutput(name: 'Toggle B', n: 8, type: switchtypes.toggle);
        expect(toggleOutput.behavior, switchtypes.toggle);
      });

      test('IpxAnalog subclass creation', () {
        final analog = IpxAnalog(name: 'Sensor X', n: 12);
        expect(analog.type, ipxtypes.analog);
        expect(analog.value, 0.0);
        expect(analog.name, 'Sensor X');
        expect(analog.n, 12);
      });

      test('IpxCounter subclass creation', () {
        final counter = IpxCounter(name: 'Counter C', n: 15);
        expect(counter.value, 0);
        expect(counter.name, 'Counter C');
        expect(counter.n, 15);
      });
      test('IpxEntity json test', () {
        final toggleOutput = IpxOutput(name: 'Toggle B', n: 8, type: switchtypes.toggle);
        String encoded = jsonEncode(toggleOutput.toJson());
        String expected = '{"name":"Toggle B","cmd":"","n":8,"value":false,"changed":false,"type":"output","switch":"toggle"}';
        expect(encoded,expected);
        final IpxOutput recovered = IpxEntity.fromJson(jsonDecode(encoded)) as IpxOutput;
        expect(recovered.name, 'Toggle B');
        expect(recovered.behavior, switchtypes.toggle);
      });
    });
    group('Ipx class', () {
      // Initialize an Ipx object for testing
      final Ipx ipx = Ipx('Test Ipx');
      test('define method should add entities to the entities map', () {
        final IpxInput input = IpxInput(name: 'Test Input', n: 0);
        final IpxOutput output = IpxOutput(name: 'Test Output', n: 1);
        ipx.define(input);
        ipx.define(output);
        expect(ipx.entities['input']![0], input);
        expect(ipx.entities['output']![1], output);

      });
      test('Ipx json test', () {
        final IpxInput input = IpxInput(name: 'Test Input', n: 0);
        final IpxOutput output = IpxOutput(name: 'Test Output', n: 1, cmd: 'toto');
        ipx.define(input);
        ipx.define(output);
        String encoded = jsonEncode(ipx.toJson());
        String expected = '{"name":"Test Ipx","port":9870,"host":"ipx.lan","entities":{"input":[{"name":"Test Input","cmd":"","n":0,"value":false,"changed":false,"type":"input"},{"name":"2","cmd":"","n":1,"value":false,"changed":false,"type":"input"},{"name":"3","cmd":"","n":2,"value":false,"changed":false,"type":"input"},{"name":"4","cmd":"","n":3,"value":false,"changed":false,"type":"input"},{"name":"5","cmd":"","n":4,"value":false,"changed":false,"type":"input"},{"name":"6","cmd":"","n":5,"value":false,"changed":false,"type":"input"},{"name":"7","cmd":"","n":6,"value":false,"changed":false,"type":"input"},{"name":"8","cmd":"","n":7,"value":false,"changed":false,"type":"input"},{"name":"9","cmd":"","n":8,"value":false,"changed":false,"type":"input"},{"name":"10","cmd":"","n":9,"value":false,"changed":false,"type":"input"},{"name":"11","cmd":"","n":10,"value":false,"changed":false,"type":"input"},{"name":"12","cmd":"","n":11,"value":false,"changed":false,"type":"input"},{"name":"13","cmd":"","n":12,"value":false,"changed":false,"type":"input"},{"name":"14","cmd":"","n":13,"value":false,"changed":false,"type":"input"},{"name":"15","cmd":"","n":14,"value":false,"changed":false,"type":"input"},{"name":"16","cmd":"","n":15,"value":false,"changed":false,"type":"input"},{"name":"17","cmd":"","n":16,"value":false,"changed":false,"type":"input"},{"name":"18","cmd":"","n":17,"value":false,"changed":false,"type":"input"},{"name":"19","cmd":"","n":18,"value":false,"changed":false,"type":"input"},{"name":"20","cmd":"","n":19,"value":false,"changed":false,"type":"input"},{"name":"21","cmd":"","n":20,"value":false,"changed":false,"type":"input"},{"name":"22","cmd":"","n":21,"value":false,"changed":false,"type":"input"},{"name":"23","cmd":"","n":22,"value":false,"changed":false,"type":"input"},{"name":"24","cmd":"","n":23,"value":false,"changed":false,"type":"input"},{"name":"25","cmd":"","n":24,"value":false,"changed":false,"type":"input"},{"name":"26","cmd":"","n":25,"value":false,"changed":false,"type":"input"},{"name":"27","cmd":"","n":26,"value":false,"changed":false,"type":"input"},{"name":"28","cmd":"","n":27,"value":false,"changed":false,"type":"input"},{"name":"29","cmd":"","n":28,"value":false,"changed":false,"type":"input"},{"name":"30","cmd":"","n":29,"value":false,"changed":false,"type":"input"},{"name":"31","cmd":"","n":30,"value":false,"changed":false,"type":"input"},{"name":"32","cmd":"","n":31,"value":false,"changed":false,"type":"input"}],"output":[{"name":"1","cmd":"","n":0,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"Test Output","cmd":"toto","n":1,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"3","cmd":"","n":2,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"4","cmd":"","n":3,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"5","cmd":"","n":4,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"6","cmd":"","n":5,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"7","cmd":"","n":6,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"8","cmd":"","n":7,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"9","cmd":"","n":8,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"10","cmd":"","n":9,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"11","cmd":"","n":10,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"12","cmd":"","n":11,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"13","cmd":"","n":12,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"14","cmd":"","n":13,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"15","cmd":"","n":14,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"16","cmd":"","n":15,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"17","cmd":"","n":16,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"18","cmd":"","n":17,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"19","cmd":"","n":18,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"20","cmd":"","n":19,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"21","cmd":"","n":20,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"22","cmd":"","n":21,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"23","cmd":"","n":22,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"24","cmd":"","n":23,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"25","cmd":"","n":24,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"26","cmd":"","n":25,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"27","cmd":"","n":26,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"28","cmd":"","n":27,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"29","cmd":"","n":28,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"30","cmd":"","n":29,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"31","cmd":"","n":30,"value":false,"changed":false,"type":"output","switch":"onoff"},{"name":"32","cmd":"","n":31,"value":false,"changed":false,"type":"output","switch":"onoff"}],"analog":[{"name":"1","cmd":"","n":0,"value":0.0,"changed":false,"type":"analog"},{"name":"2","cmd":"","n":1,"value":0.0,"changed":false,"type":"analog"},{"name":"3","cmd":"","n":2,"value":0.0,"changed":false,"type":"analog"},{"name":"4","cmd":"","n":3,"value":0.0,"changed":false,"type":"analog"},{"name":"5","cmd":"","n":4,"value":0.0,"changed":false,"type":"analog"},{"name":"6","cmd":"","n":5,"value":0.0,"changed":false,"type":"analog"},{"name":"7","cmd":"","n":6,"value":0.0,"changed":false,"type":"analog"},{"name":"8","cmd":"","n":7,"value":0.0,"changed":false,"type":"analog"},{"name":"9","cmd":"","n":8,"value":0.0,"changed":false,"type":"analog"},{"name":"10","cmd":"","n":9,"value":0.0,"changed":false,"type":"analog"},{"name":"11","cmd":"","n":10,"value":0.0,"changed":false,"type":"analog"},{"name":"12","cmd":"","n":11,"value":0.0,"changed":false,"type":"analog"},{"name":"13","cmd":"","n":12,"value":0.0,"changed":false,"type":"analog"},{"name":"14","cmd":"","n":13,"value":0.0,"changed":false,"type":"analog"},{"name":"15","cmd":"","n":14,"value":0.0,"changed":false,"type":"analog"},{"name":"16","cmd":"","n":15,"value":0.0,"changed":false,"type":"analog"}],"counter":[{"name":"1","cmd":"","n":0,"value":0,"changed":false,"type":"counter"},{"name":"2","cmd":"","n":1,"value":0,"changed":false,"type":"counter"},{"name":"3","cmd":"","n":2,"value":0,"changed":false,"type":"counter"},{"name":"4","cmd":"","n":3,"value":0,"changed":false,"type":"counter"},{"name":"5","cmd":"","n":4,"value":0,"changed":false,"type":"counter"},{"name":"6","cmd":"","n":5,"value":0,"changed":false,"type":"counter"},{"name":"7","cmd":"","n":6,"value":0,"changed":false,"type":"counter"},{"name":"8","cmd":"","n":7,"value":0,"changed":false,"type":"counter"}]}}';
        expect(encoded,expected);
        final Ipx recovered = Ipx.fromJson(jsonDecode(encoded));
        expect(recovered.name, 'Test Ipx');
        IpxEntity? entity = recovered.getEntity('toto');
        expect(entity,isNotNull);
        expect(entity!.cmd,'toto');
        entity = recovered.findEntity('toto');
        expect(entity,isNotNull);
        expect(entity!.cmd,'toto');
      });
      test('statusChange method should update the state of outputs and inputs', () {
        // Define some inputs and outputs for testing
        final IpxInput input = IpxInput(name: 'Test Input', n: 0);
        final IpxOutput output = IpxOutput(name: 'Test Output', n: 1);

        ipx.define(input);
        ipx.define(output);

        // Call the statusChange method with sample data
        final Map<String, String> args = {'out': '11', 'in': '00'};
        final List<String> changed = ipx.statusChange(args);

        // Check that the state of the output was updated
        expect(ipx.getState('output', 1), true);
        // Check that the list of changed entities includes the output
        expect(changed, contains('Test Output'));

        // Check that the state of the input was not updated
        expect(ipx.getState('input', 0), false);

        expect(changed, isNot(contains('Test Input')));
      });
      test('find method should return the key and index of the entity', () {
        // Define some entities for testing
        final IpxInput input1 = IpxInput(name: 'Test Input 1', n: 0);
        final IpxInput input2 = IpxInput(name: 'Test Input 2', n: 1);
        final IpxOutput output = IpxOutput(name: 'Test Output', n: 2);
        ipx.define(input1);
        ipx.define(input2);
        ipx.define(output);

        // Check that the find method returns the correct key and index for the input entities
        expect(ipx.find('Test Input 1'), Tuple2<String, int>('input', 0));
        expect(ipx.find('Test Input 2'), Tuple2<String, int>('input', 1));

        // Check that the find method returns the correct key and index for the output entity
        expect(ipx.find('Test Output'), Tuple2<String, int>('output', 1));
        // Check that the find method returns the correct key and index for an unknown entity
        expect(ipx.find('Unknown Entity'), Tuple2<String, int>('unknown', -1));
      });
      group('IpxMap', () {
        test('should add and retrieve values correctly', () {
          final ipxMap = IpxMap();
          final ipx1 = Ipx("one");
          final ipx2 = Ipx("two");

          // Add values to the map
          ipxMap['key1'] = ipx1;
          ipxMap['key2'] = ipx2;

          // Check if keys exist
          expect(ipxMap.containsKey('key1'), isTrue);
          expect(ipxMap.containsKey('key2'), isTrue);

          // Retrieve values and compare
          expect(ipxMap['key1'], equals(ipx1));
          expect(ipxMap['key2'], equals(ipx2));
        });

        test('should return null when key not found', () {
          final ipxMap = IpxMap();

          // Retrieving a value for a key that doesn't exist should return null
          expect(ipxMap['nonexistent_key'], isNull);
        });

        test('should find entities correctly', () {
          final ipxMap = IpxMap();
          final ipx1 = Ipx("one");
          final ipx2 = Ipx("two");
          final message1 = 'Test Input';
          final message2 = 'Test Output';

          // Add entities to Ipx objects
          ipx1.define(IpxInput(name: message1, n: 0));
          ipx2.define(IpxOutput(name: message2, n: 1,cmd: 'toto'));

          // Add Ipx objects to the map
          ipxMap['key1'] = ipx1;
          ipxMap['key2'] = ipx2;
          expect(ipxMap.find(message1), isNotNull);
          expect(ipxMap.find(message2), isNotNull);
          expect(ipx1.findEntity(message1), isNotNull);
          expect(ipx2.findEntity(message2), isNotNull);
          expect(ipx2.getEntity('toto'), isNotNull);

          // Find entities by message
          expect(ipxMap.find(message1), equals(ipx1.findEntity(message1)));
          expect(ipxMap.find(message2), equals(ipx2.findEntity(message2)));
          expect(ipxMap.find(message2), equals(ipx2.getEntity('toto')));
        });

        test('should find entities correctly', () {
          final ipxMap = IpxMap();
          final ipx1 = Ipx("one");
          final ipx2 = Ipx("two");
          final message1 = 'Test Input';
          final message2 = 'Test Output';
          // Add Ipx objects to the map
          ipxMap['key1'] = ipx1;
          ipxMap['key2'] = ipx2;

          // Add entities to Ipx objects
          ipx1.define(IpxInput(name: message1, n: 0));
          ipx2.define(IpxOutput(name: message2, n: 1,cmd: 'toto'));

          String json = ipxMap.toJson();
          IpxMap recov = IpxMap.fromJson(json);

          expect(recov.find(message1), isNotNull);
          expect(recov.find(message2), isNotNull);
          expect(ipx1.findEntity(message1), isNotNull);
          expect(ipx2.findEntity(message2), isNotNull);
          expect(ipx2.getEntity('toto'), isNotNull);

          // Find entities by message
          expect(recov.find(message1), equals(ipx1.findEntity(message1)));
          expect(recov.find(message2), equals(ipx2.findEntity(message2)));
          expect(recov.find(message2), equals(ipx2.getEntity('toto')));
        });


      });

    });
}
