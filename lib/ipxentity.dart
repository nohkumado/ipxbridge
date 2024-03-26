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
  ipxtypes get type;
   /// The name of the entity.
  final String name;
  /// The entity's position (n).
  final int n;
  /// The value of the entity, with the specific type determined by the subclass.
  late T value;
  bool changed = false;
/// Constructor for the IpxEntity class.
  IpxEntity({required this.name, required this.n});

  bool update(String value);
  @override
  String toString() {
    return 'IE{$name@$n: $value}';
  }

}

/// Class representing an IPX input entity.
class IpxInput extends IpxEntity<bool>
{
  @override
  bool value = false;
  IpxInput({required String name, required int n}) : super(name: name, n: n);

  @override
  bool update(String newval) {
    final bool previous = value;
    value = newval == '1';
    changed = value != previous;
    return changed;
  }

  @override
  ipxtypes get type => ipxtypes.input;
}
/// Class representing an IPX output entity.
class IpxOutput extends IpxEntity<bool>
{
  @override
  bool value = false;
  late switchtypes behavior;
  IpxOutput({required String name, required int n, switchtypes type = switchtypes.onoff }) : super(name: name, n: n) {
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
}
