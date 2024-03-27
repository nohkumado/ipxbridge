import 'ipxentity.dart';
import 'package:tuple/tuple.dart';
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

  Map<String,List<IpxEntity>> entities =
  {
    "input" : List<IpxInput>.generate(32, (index) => IpxInput(name: '${(index+1)}', n: index)),
    "output" : List<IpxOutput>.generate(32, (index) => IpxOutput(name: '${(index+1)}', n: index)),
    "analog" : List<IpxAnalog>.generate(16, (index) => IpxAnalog(name: '${(index+1)}', n: index)),
    "counter" : List<IpxCounter>.generate(8, (index) => IpxCounter(name: '${(index+1)}', n: index)),
  };


  bool debug = true;



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
  List<String> statusChange(Map<String, String> args) {
    // Initialize outputs and inputs based on the provided arguments

    List<String> changed = [];

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

  void _updateNumericState({required String data, required String key, required List<String> changed}) {
    List<String> values = data.split(',').map((value) => value.trim()).toList();
    // Remove the trailing colon from the last value
    if (values.isNotEmpty) {
      values.last = values.last.replaceAll(':', '');
    }
    for (int i = 0; i < values.length; i++) {
      IpxEntity  entity = entities[key]![i];
      if(entity.update(values[i])) {changed.add(entity.name);}
    }
  }

  List<String> _updateState({required String key,required String data, required List<String> changed})
  {
    for (int n = 0; n < data.length; n++) {
      if(entities[key]![n].update(data[n])) {changed.add(entities[key]![n].name);}
    }
    return changed;
  }

  Tuple2<String, int>  find(String s)
  {
    for(String key in entities.keys)
      {
        int indexof = 0;
        while(indexof < entities[key]!.length)
          {
            if(entities[key]![indexof].name == s) return Tuple2<String,int>(key,indexof);
            indexof++;
          }
      }
    return Tuple2<String,int>("unknown",-1);
  }

  bool getState(String item1, int item2)
  {
    if(entities.containsKey(item1) && entities[item1]!.length > item2) {
      dynamic val = entities[item1]?[item2].value;
      if (val is bool) return val;
      print("wrong type of entity, no bool: $item1 : $item2 ${entities[item1]?[item2]}");
    }
    print("no suche element $item1 : $item2");
    return false;
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

  IpxEntity? getEntity(String message)
  {
    if(cmds.containsKey(message)) return cmds[message];
    return null;
  }

  IpxEntity? findEntity(String cmd)
  {
    for(String key in entities.keys)
    {
      int indexof = 0;
      while(indexof < entities[key]!.length)
      {
        if(entities[key]![indexof].name == cmd) return entities[key]![indexof];
        indexof++;
      }
    }
    return null;
  }
}

class IpxMap
{
  // Internal map to store key-value pairs
  Map<String,Ipx> ipxes = {};
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
  // Method for finding an entity by searching through the values of the map
  // Returns the found entity or null if not found
  IpxEntity? find(String message)
  {
    IpxEntity? res ;
    // Loop through each configured command in the map
    for(String key in ipxes.keys)
      {
        res = ipxes[key]?.getEntity(message);
        if(res != null) return res;
      }
    // Loop through each entity in the map
    for(String key in ipxes.keys)
    {
      res = ipxes[key]?.findEntity(message);
      if(res != null) return res;
    }
    //nothing found
    return null;
  }
}
