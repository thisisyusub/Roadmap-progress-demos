import 'dart:async';
import 'dart:math';

void main() {
  final stateContext = StateContext();

  stateContext.outState.listen((state) {
    print(state.render());
  });

  stateContext.nextState();
}

abstract interface class IState {
  Future<void> nextState(StateContext context);
  String render();
}

class StateContext {
  final _stateStream = StreamController<IState>();
  Sink<IState> get _inState => _stateStream.sink;
  Stream<IState> get outState => _stateStream.stream;

  late IState _currentState;

  StateContext() {
    _currentState = const NoResultsState();
    _addCurrentStateToStream();
  }

  void dispose() {
    _stateStream.close();
  }

  void setState(IState state) {
    print('Setting state to ${state.runtimeType}');
    _currentState = state;
    _addCurrentStateToStream();
  }

  void _addCurrentStateToStream() {
    _inState.add(_currentState);
  }

  Future<void> nextState() async {
    print('Next state called on ${_currentState.runtimeType}');
    await _currentState.nextState(this);

    if (_currentState is LoadingState) {
      await _currentState.nextState(this);
    }
  }
}

class ErrorState implements IState {
  const ErrorState();

  @override
  Future<void> nextState(StateContext context) async {
    context.setState(const LoadingState());
  }

  @override
  String render() {
    return 'Error State';
  }
}

class LoadedState implements IState {
  const LoadedState(this.names);

  final List<String> names;

  @override
  Future<void> nextState(StateContext context) async {
    context.setState(const LoadingState());
  }

  @override
  String render() {
    return 'Loaded State';
  }
}

class NoResultsState implements IState {
  const NoResultsState();

  @override
  Future<void> nextState(StateContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    context.setState(const LoadingState());
  }

  @override
  String render() {
    return 'No Results State';
  }
}

class LoadingState implements IState {
  const LoadingState({
    this.api = const FakeApi(),
  });

  final FakeApi api;

  @override
  Future<void> nextState(StateContext context) async {
    try {
      final resultList = await api.getNames();

      context.setState(
        resultList.isEmpty ? const NoResultsState() : LoadedState(resultList),
      );
    } on Exception {
      context.setState(const ErrorState());
    }
  }

  @override
  String render() {
    return 'Loading State';
  }
}

class FakeApi {
  const FakeApi();

  Future<List<String>> getNames() => Future.delayed(
        const Duration(seconds: 2),
        () {
          if (Random().nextBool()) return _getRandomNames();
          throw Exception('Unexpected error');
        },
      );

  List<String> _getRandomNames() => List.generate(
        3,
        (_) => 'Name ${Random().nextInt(100)}',
      );
}
