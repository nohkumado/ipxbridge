/// Abstract base class representing an IPX entity.
///
/// This class provides common properties for different types of IPX entities
/// and utilizes generics to allow subclasses to specify the type of the `value` property.
/// Enum representing the different types of IPX entities.
enum ipxtypes {input, output,analog,counter}
/// Enum representing different types of output entities (optional).
enum switchtypes {button, toggle, onoff}
abstract class IpxEntity<T>
{
  /// The name of the entity.
  final String name;
  /// The command name to call this entity.
  String cmd = "";
  /// The entity's position (n).
  final int n;
  /// The value of the entity, with the specific type determined by the subclass.
  late T value;
  bool changed = false;

  String help = '';
  String get valueString => value.toString();
  String get cmdString => cmd.isEmpty ? '' : ' $cmd';

  ipxtypes get type;
/// Constructor for the IpxEntity class.
  IpxEntity({required this.name, required this.n, String cmd = '', String help = ''}) {
    if(cmd.isNotEmpty) {
      this.cmd = cmd;
      if(help.isNotEmpty) this.help = help;
      else
        this.help = cmd;
    }
}

  bool update(String value);
  @override
  String toString() {
    return 'IE{$name@$n: $value}';
  }
// Method to serialize the IpxEntity to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cmd': cmd,
      'n': n,
      'value': value,
      'changed': changed,
      'type': entityType(),
    };
  }

  // Abstract factory method to create the value from JSON
  T valueFromJson(dynamic json);
  // Abstract factory method to create the value from JSON
  String entityType();

  // Factory method to deserialize the IpxEntity from a JSON Map
  factory IpxEntity.fromJson(Map<String, dynamic> json) {
    IpxEntity<T> entity;
    switch (json['type']) {
     case 'input': entity = IpxInput(name: json['name'], n: json['n'], cmd: json['cmd']??'') as IpxEntity<T>; break;
      case 'output': entity = IpxOutput(name: json['name'], n: json['n'], cmd: json['cmd']??'', type: switchTypesFromJson(json['switch'])) as IpxEntity<T>; break;
      case 'analog': entity = IpxAnalog(name: json['name'], n: json['n']) as IpxEntity<T>; break;
      case 'counter': entity = IpxCounter(name: json['name'], n: json['n']) as IpxEntity<T>; break;
      default: throw Exception('Unknown entity type: ${json['type']}');
    };
    entity.value = entity.valueFromJson(json['value']);
    return entity;
  }

  // Method to deserialize the enum value from JSON
  static switchtypes switchTypesFromJson(String json) {
    return switchtypes.values.firstWhere(
          (type) => type.toString().split('.').last == json,
      orElse: () => switchtypes.onoff, // Default value or error handling
    );
  }

}

/// Class representing an IPX input entity.
class IpxInput extends IpxEntity<bool>
{
  @override
  bool value = false;
  IpxInput({required String name, required int n, String cmd =''}) : super(name: name, n: n, cmd: cmd);

  @override
  bool update(String newval) {
    final bool previous = value;
    value = newval == '1';
    changed = value != previous;
    return changed;
  }

  @override
  ipxtypes get type => ipxtypes.input;

  @override
  bool valueFromJson(json) {
    return value;
  }

  @override
  String entityType() {
    return 'input';
  }
}
/// Class representing an IPX output entity.
class IpxOutput extends IpxEntity<bool>
{
  @override
  bool value = false;
  late switchtypes behavior;
  IpxOutput({required String name, required int n, switchtypes type = switchtypes.onoff, String cmd =''}) : super(name: name, n: n, cmd: cmd) {
    behavior = type;
  }
  @override
  ipxtypes get type => ipxtypes.output;
  @override
  bool update(String newval) {
    final bool previous = value;
    value = newval == '1';
    changed = value != previous;
    return changed;
  }
  @override
  bool valueFromJson(json) {
    return value;
  }
  @override
  String entityType() {
    return 'output';
  }
  // Method to serialize the IpxEntity to a JSON Map
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> prev = super.toJson();
    prev['switch'] = behavior.toString().split('.').last;
    return prev;
  }
}
/// Class representing an IPX analog entity
class IpxAnalog extends IpxEntity<double>
{
  @override
  double value = 0;
  IpxAnalog({required String name, required int n}) : super(name: name, n: n);
  @override
  ipxtypes get type => ipxtypes.analog;
  @override
  bool update(String newval) {
    final double previous= value;
    value = double.tryParse(newval)??0;
    changed = value != previous;
    return changed;
  }
  @override
  double valueFromJson(json) {
    return value;
  }
  @override
  String entityType() {
    return 'analog';
  }
}
/// Class representing an IPX counter entity.
class IpxCounter extends IpxEntity<int>
{
  @override
  int value = 0;
  IpxCounter({required String name, required int n}) : super(name: name, n: n);
  @override
  ipxtypes get type => ipxtypes.counter;
  bool update(String newval) {
    final int previous= value;
    value = int.tryParse(newval)??0;
    changed = value != previous;
    return changed;
  }
  @override
  int valueFromJson(json) {
    return value;
  }
  @override
  String entityType() {
    return 'counter';
  }
}
