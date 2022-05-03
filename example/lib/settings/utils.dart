

class Tuple<A,B> {
  final A value;
  final B name;

  const Tuple(this.value, this.name);

  //
  //
  // compare by value
  @override
  bool operator ==(Object other) {

    if (other is Tuple<A,B>) {
      return (other.value == value);
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}

class NamedValue<V> extends Tuple<V, String> {
  const NamedValue(V value, String name) : super(value, name);

  @override
  String toString() => name;
}






