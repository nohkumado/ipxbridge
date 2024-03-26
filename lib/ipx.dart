import 'dart:ffi';

class Ipx
{
  String name;
  int port;
  String host;

  Map<String,List<String>> names =
  {
    "input" : List<String>.generate(32, (index) => '${(index+1)}'),
    "output" : List<String>.generate(32, (index) => '${(index+1)}'),
    "analog" : List<String>.generate(16, (index) => '${(index+1)}'),
    "counter" : List<String>.generate(8, (index) => '${(index+1)}'),
  };
  Map<String,List<bool>> states =
  {
    "input" : List.filled(32, false),
    "output" :  List.filled(32, false),
  };
  Map<String,List<num>> numStates =
  {
    "analog" : List.filled(32, 0.0),
    "counter" :  List.filled(32, 0),
  };

  bool debug = true;



  Ipx(this.name, {this.port = 9870, this.host = 'ipx.lan'});
  // Method to update input name
  Ipx input({required int n, required String name})
  {
    if(n>0) n=n-1;
    names["input"]![n] = name;
    return this;
  }
  // Method to update output name
  Ipx output({required int n, required String name})
  {
    if(n>0) n=n-1;
    names["output"]![n] = name;
    return this;
  }
  // Method to update analog name
  Ipx analog({required int n, required String name})
  {
    if(n>0) n=n-1;
    names["analog"]![n] = name;
    return this;
  }
   // Method to update counter name
  Ipx counter({required int n, required String name})
  {
    if(n>0) n=n-1;
    names["counter"]![n] = name;
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

    if(debug)print("Returning changed: $changed");
    return changed;
  }

  void _updateNumericState({required String data, required String key, required List<String> changed}) {
    List<String> values = data.split(',').map((value) => value.trim()).toList();
    // Remove the trailing colon from the last value
    if (values.isNotEmpty) {
      values.last = values.last.replaceAll(':', '');
    }
    for (int i = 0; i < values.length; i++) {
      String counterValue = values[i];
      num previousValue = numStates[key]![i];
      numStates[key]![i] = int.parse(counterValue);
      if(numStates[key]![i] != previousValue)changed.add("$key:${names[key]![i]}: ${numStates[key]![i]}");
    }
  }

  List<String> _updateState({required String key,required String data, required List<String> changed})
  {
    for (int n = 0; n < data.length; n++) {
      bool previous = states[key]![n];
      states[key]![n] = data[n] == '1';
      if (previous != states[key]![n]) {
        if(debug) print("status change for $key:${names[key]![n]}: ${states[key]![n]}");
        changed.add(names[key]![n]);
      }
    }
    return changed;
  }
}