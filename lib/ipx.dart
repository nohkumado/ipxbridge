import 'dart:convert';
import 'ipxentity.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
/// description of an Ipx, the home automation system
/// notable the names of the different inputs and outputs, counters and analogs
/// holds also the state to record the changes,
/// also host and port to find it on the network
class Ipx
{
  String name; //short name of this ipx
  int port; //the m2m port of this ipx, to see later if we use it at all
  String host; //the hostname of this ipx
  Map<String,IpxEntity> cmds = {};
  bool debug = true;

  Map<String,List<IpxEntity>> entities =
  {
    "input" : List<IpxInput>.generate(32, (index) => IpxInput(name: '${(index+1)}', n: index)),
    "output" : List<IpxOutput>.generate(32, (index) => IpxOutput(name: '${(index+1)}', n: index)),
    "analog" : List<IpxAnalog>.generate(16, (index) => IpxAnalog(name: '${(index+1)}', n: index)),
    "counter" : List<IpxCounter>.generate(8, (index) => IpxCounter(name: '${(index+1)}', n: index)),
  };





  Ipx(this.name, {this.port = 9870, this.host = 'ipx.lan'});
  // Method to update input name
  Ipx define(IpxEntity entity)
  {
    if(entity is IpxInput) entities["input"]![entity.n] = entity;
    else if(entity is IpxOutput) entities["output"]![entity.n] = entity;
    else if(entity is IpxAnalog) entities["analog"]![entity.n] = entity;
    else if(entity is IpxCounter) entities["counter"]![entity.n] = entity;
    else print("Error, unknown entity : $entity");
    if(entity.cmd.isNotEmpty) cmds[entity.cmd] = entity;
    return this;
  }

  /// Updates the state of outputs and inputs based on the provided arguments.
  /// Returns a list of names of the changed outputs and inputs.
  List<IpxEntity> statusChange(Map<String, String> args) {
    // Initialize outputs and inputs based on the provided arguments

    List<IpxEntity> changed = [];

    // Update outputs
    String data = args["out"] ?? "00000000000000000000000000000000";
    _updateState(key:"output",data:data, changed:changed);

    // Update inputs
    data = args["in"] ?? "00000000000000000000000000000000";
    _updateState(key:"input",data:data, changed:changed);

    data = args["counter"]??"";
    _updateNumericState(key: 'counter',data : data, changed:changed);


    data = args["analog"]??"";
    _updateNumericState(key: 'analog',data : data, changed:changed);

    return changed;
  }

  void _updateNumericState({required String data, required String key, required List<IpxEntity> changed}) {
    List<String> values = data.split(',').map((value) => value.trim()).toList();
    // Remove the trailing colon from the last value
    if (values.isNotEmpty) {
      values.last = values.last.replaceAll(':', '');
    }
    for (int i = 0; i < values.length; i++) {
      IpxEntity  entity = entities[key]![i];
      if(entity.update(values[i])) {changed.add(entity);}
    }
  }

  List<IpxEntity> _updateState({required String key,required String data, required List<IpxEntity> changed})
  {
    for (int n = 0; n < data.length; n++) {
      if(entities[key]![n].update(data[n])) {changed.add(entities[key]![n]);}
    }
    return changed;
  }

  IpxEntity?  find(String s)
  {
    for(String key in entities.keys)
      {
        int indexof = 0;
        while(indexof < entities[key]!.length)
          {
            if(entities[key]![indexof].name == s) return entities[key]![indexof];
            indexof++;
          }
      }
    return null;
  }

  bool getState({IpxEntity? entity, String genre= "", int index = 10000})
  {
    if(entity != null) {
      print("getStage fE, $entity val: ${entity.value}");
      index = entity.n;
      if(entity is IpxInput)
       {
         genre= "input";
       }
      else if(entity is IpxOutput)
      {
        genre= "output";
      }
      else if(entity is IpxAnalog)
      {
        genre= "analog";
      }
      else if(entity is IpxCounter)
      {
        genre= "counter";
      }
      else genre ="unknown";
    }


    if(entities.containsKey(genre) && entities[genre]!.length > index) {
      dynamic val = entities[genre]?[index].value;
      print("==getStage , val: ${val}");
      if (val is bool) return val;
      print("wrong type of entity, no bool: $genre : $index ${entities[genre]?[index]}");
    }
    //print("IP:getState no suche element $item1 : $item2, available: ${entities.keys}");
    return false;
  }
  bool toggleState({required IpxEntity entity})
  {
    entity.value = !entity.value;
    return entity.value;
  }

  String compileHelp()
  {
    StringBuffer res = StringBuffer();
    for(String key in cmds.keys)
      {
        res.write("${cmds[key]!.name} : ${cmds[key]!.help}\n");
      }
    return res.toString();
  }
  /// Returns the entity with the specified name stored in commands, or null if not found.
  IpxEntity? getEntity(String message)
  {
    if(cmds.containsKey(message)) return cmds[message];
    return null;
  }

  /// whether it is a stored command or any unconfigured entity, try to find it and return, null otherwise
  IpxEntity? findEntity(String cmd)
  {
    IpxEntity? result = getEntity(cmd); //check if is a defined stored command
    if(result != null) return result;
    for(String key in entities.keys)
    {
      int indexof = 0;
      while(indexof < entities[key]!.length)
      {
        if(entities[key]![indexof].name == cmd ) return entities[key]![indexof];
        indexof++;
      }
    }
    return null;
  }

  Map<String, dynamic>  toJson() {
    return {
      'name': name,
      'port': port,
      'host': host,
      //'cmds': cmds.map((key, value) => MapEntry(key, value.toJson())),
      'entities': entities.map((key, value) => MapEntry(key, value.map((entity) => entity.toJson()).toList())),
    };
  }

  // Method to deserialize the Ipx object from a JSON Map
  factory Ipx.fromJson(Map<String, dynamic> json) {
    var ipx = Ipx(json['name'], port: json['port'], host:json['host']);
    /*json['cmds'].forEach((key, value) {
      ipx.cmds[key] = IpxEntity.fromJson(value);
    }); */
    // Deserialize entities map
    json['entities'].forEach((key, value) {
      ipx.entities[key] = (value as List<dynamic>).map((entityJson) {
        IpxEntity entity = IpxEntity.fromJson(entityJson);
        if(entity.cmd.isNotEmpty) {
          ipx.cmds[entity.cmd] = entity;
        }
        return entity;
      }).toList();
    });
    return ipx;
  }

  Future<String> schalte({required String sender, required IpxEntity schalter})
  async {
    StringBuffer result = StringBuffer();
    // Craft the message for the room
    String verb = "schalte";
    bool istrigger = false;
    if(schalter is IpxOutput && schalter.behavior ==  switchtypes.button) {
      verb = "betätige";
      istrigger = true;
    }

    result.writeln("Hai ${sender}! $verb ${schalter.name}");
    if(!istrigger) result.writeln((schalter.value)? " aus" :" ein");
    result.writeln("!");
    //final Uri url=Uri(scheme: 'http', host: actIps.host, path: 'protect/assignio/assign1.htm');
    Uri url=(istrigger)?Uri(scheme: 'http', host: host, path: 'leds.cgi') :Uri(scheme: 'http', host: host, path: 'preset.htm');
    ;
    //url.queryParameters['set${(schalter.n+1)}'] = (!getState(schalter.name,schalter.n)).toString();
    //print("debug issuing ${url.query}");

// Create a mutable copy using spread operator
    Map<String, String> queryParameters = new Map<String, String>.from(url.queryParameters);
    // Modify the query parameters in the copy
    if(istrigger)queryParameters['led'] = schalter.n.toString();
    else {
      //queryParameters['set${schalter.n+1}'] = ((!getState(entity: schalter))?'1':'0').toString();
      queryParameters['set${schalter.n+1}'] = ((toggleState(entity: schalter))?'1':'0').toString();
    }
    // Reconstruct the Uri with the modified query parameters
    url = url.replace(queryParameters: queryParameters);
    print("#############   debug issuing ${url}");
    // Now you can use the modified url object

    //keep for further reference API info:
    //url.queryParameters('relayname', 'porte garage');
    // Set delay parameters (assuming these are supported by the API)
    //url.queryParameters['delayon'] = 0.toString();
    //url.queryParameters['delayoff'] = 5.toString();
    // Send the URI request using an appropriate HTTP client library
    // (assuming post2Room doesn't handle this functionality)
    final response = await http.get(url); // Use http.get for GET requests

    if (response.statusCode == 200) {
      //result.writeln("sent success"); // Indicate success
    } else {
      result.writeln("Error sending toggle '$schalter.name' request: ${response.statusCode}");
    }
    return result.toString();
  }

}

/*class IpxMap
{
  // Internal map to store key-value pairs
  final Map<String,Ipx> ipxes = const {};
  const IpxMap();
  // Getter for keys
  get keys => ipxes.keys;
  // Operator [] for reading values
  Ipx? operator[](String key)
  {
    return ipxes[key];
  }
  // Operator []= for assigning values
  void operator []=(String key, Ipx value) {
    ipxes[key] = value;
  }
  // Method for checking if key exists
  bool containsKey(String? arg)
  {
    return ipxes.containsKey(arg);
  }
  // Method for finding an entity by searching through first the commands and then the configuration of the ipx'es
  // Returns the found entity or null if not found
  Tuple2<Ipx,IpxEntity>? find(String message)
  {
    IpxEntity? res ;
    // Loop through each configured command in the map
    for(String key in ipxes.keys)
      {
        res = ipxes[key]?.findEntity(message);
        if(res != null) return Tuple2(ipxes[key]!, res);
      }
    //nothing found
    return null;
  }
  // Method to serialize the IpxMap to a JSON string
  String toJson() {
    Map<String, dynamic> jsonMap = {};
    ipxes.forEach((key, ipx) {
      jsonMap[key] = ipx.toJson();
    });
    return jsonEncode(jsonMap);
  }

  // Method to deserialize the IpxMap from a JSON string
  static IpxMap fromJson(String jsonStr) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
    IpxMap ipxes = IpxMap(); // Clear the existing map
    jsonMap.forEach((key, value) {
      ipxes[key] = Ipx.fromJson(value);
    });
    return ipxes;
  }

  String compileIpxCmds()
  {
    StringBuffer res = StringBuffer();
    for(String key in ipxes.keys)
    {
      res.write('${ipxes[key]!.compileHelp()}');
    }
    return res.toString();
  }

}
*/
class IpxMap {
  // Internal map to store key-value pairs
  Map<String, Ipx> ipxes = {}; // Use private field for encapsulation

  // Factory constructor for creating immutable instances
  factory IpxMap.fromMap(Map<String, Ipx> initialIpxes) {
    final ipxMap = IpxMap._internal();
    ipxMap.ipxes.addAll(initialIpxes);
    return ipxMap;
  }

 IpxMap({Map<String, Ipx>?map}) {
    if(map!=null) ipxes = map;
 }
  // Internal constructor for creating an empty instance
  IpxMap._internal(); // Private constructor to enforce factory pattern

  // Getter for all Ipx keys (immutable view)
  Iterable<String> get keys => ipxes.keys;

  // Operator [] for reading values (immutable)
  Ipx? operator [](String key) => ipxes[key];
  // Operator []= for assigning values
  void operator []=(String key, Ipx value) {
    ipxes[key] = value;
  }

  // Method for checking if key exists
  bool containsKey(String key) => ipxes.containsKey(key);

  // Method for finding an entity by searching through Ipx commands
  // Returns the found entity or null if not found
  Tuple2<Ipx, IpxEntity>? find(String message) {
    for (final ipx in ipxes.values) {
      final entity = ipx.findEntity(message);
      if (entity != null) {
        return Tuple2(ipx, entity);
      }
    }
    return null;
  }

  // Method to serialize the IpxMap to a JSON string
  String toJson() {
    final jsonMap = {};
    ipxes.forEach((key, ipx) => jsonMap[key] = ipx.toJson());
    return jsonEncode(jsonMap);
  }

  // Method to deserialize the IpxMap from a JSON string (use factory constructor)
  factory IpxMap.fromJson(String jsonStr) {
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    final ipxMap = IpxMap._internal();
    jsonMap.forEach((key, value) => ipxMap.ipxes[key] = Ipx.fromJson(value));
    return ipxMap;
  }

  // Method to compile Ipx commands into a single string
  String compileIpxCmds() {
    final buffer = StringBuffer();
    for (final ipx in ipxes.values) {
      buffer.write(ipx.compileHelp());
    }
    return buffer.toString();
  }
}
