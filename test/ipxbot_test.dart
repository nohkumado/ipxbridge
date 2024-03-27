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
          final message1 = 'message1';
          final message2 = 'message2';

          // Add entities to Ipx objects
          ipx1.define(IpxInput(name: 'Test Input', n: 0));
          ipx2.define(IpxOutput(name: 'Test Output', n: 1));

          // Add Ipx objects to the map
          ipxMap['key1'] = ipx1;
          ipxMap['key2'] = ipx2;

          // Find entities by message
          expect(ipxMap.find(message1), equals(ipx1.getEntity(message1)));
          expect(ipxMap.find(message2), equals(ipx2.getEntity(message2)));
        });
      });

    });
}
