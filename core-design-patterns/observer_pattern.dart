void main() {
  NumberConverter converter = NumberConverter();

  BinaryObserver(converter);
  OctalObserver(converter);
  HexObserver(converter);

  converter.value = 15;
  converter.notifyObservers();

  converter.value = 10;
  converter.notifyObservers();
}

base class NumberConverter {
  List<NumberObserver> _observers = [];
  int value = 0;

  void addObserver(NumberObserver observer) {
    _observers.add(observer);
  }

  void removeObserver(NumberObserver observer) {
    _observers.remove(observer);
  }

  void notifyObservers() {
    _observers.forEach((observer) => observer.update());
  }
}

abstract interface class NumberObserver {
  NumberObserver(NumberConverter converter) {
    this.converter = converter;
    this.converter.addObserver(this);
  }

  late final NumberConverter converter;
  void update();
}

class BinaryObserver extends NumberObserver {
  BinaryObserver(NumberConverter converter) : super(converter);

  @override
  void update() {
    print('Binary String: ${converter.value.toRadixString(2)}');
  }
}

class OctalObserver extends NumberObserver {
  OctalObserver(NumberConverter converter) : super(converter);

  @override
  void update() {
    print('Octal String: ${converter.value.toRadixString(8)}');
  }
}

// hexadecimal

class HexObserver extends NumberObserver {
  HexObserver(NumberConverter converter) : super(converter);

  @override
  void update() {
    print('Octal String: ${converter.value.toRadixString(16)}');
  }
}
