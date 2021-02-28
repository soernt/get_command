library get_command;

import 'dart:async';
import 'package:get_rx/get_rx.dart';

typedef VoidFunc = FutureOr<void> Function();
typedef VoidFuncWith1Parameter<P1> = FutureOr<void> Function(P1 p1);
typedef VoidFuncWith2Parameters<P1, P2> = FutureOr<void> Function(P1 p1, P2 p2);
typedef VoidFuncWith3Parameters<P1, P2, P3> = FutureOr<void> Function(
    P1 p1, P2 p2, P3);

typedef ErrorMessageProvider = FutureOr<String> Function(Exception exception);

class GetCommandP3<P1, P2, P3> extends _CommandBase {
  VoidFuncWith3Parameters<P1, P2, P3> commandFunc;

  GetCommandP3({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  FutureOr<void> call(P1 p1, P2 p2, P3 p3) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc(p1, p2, p3));
  }
}

class GetCommandP2<P1, P2> extends _CommandBase {
  VoidFuncWith2Parameters<P1, P2> commandFunc;

  GetCommandP2({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  FutureOr<void> call(P1 p1, P2 p2) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc(p1, p2));
  }
}

class GetCommandP1<P1> extends _CommandBase {
  VoidFuncWith1Parameter<P1> commandFunc;

  GetCommandP1({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  FutureOr<void> call(P1 p1) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc(p1));
  }
}

class GetCommand extends _CommandBase {
  VoidFunc commandFunc;

  GetCommand({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  FutureOr<void> call() {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc());
  }
}

abstract class _CommandBase {
  final Rx<CommandState> state;

  ErrorMessageProvider errorMessageProviderFunc;

  bool get enabled => state.value.enabled;

  bool get executing => state.value.executing;

  bool get canBeExecuted => enabled && !executing;

  bool get hasError => state.value.hasErrorMessage;

  String get errorMessage => state.value.errorMessage;

  _CommandBase({bool enabled = true, bool executing = false})
      : state = CommandState(enabled, executing, '').obs;

  FutureOr<void> _doExecute(
      FutureOr<void> Function() internalCommandFunc) async {
    assert(internalCommandFunc != null);

    if (!state.value.enabled) {
      return null;
    }

    setState(executing: true);
    try {
      await internalCommandFunc();
    } on Exception catch (ex) {
      await _setError(ex);
    } finally {
      setState(executing: false);
    }
  }

  Future<void> _setError(Exception exception) async {
    var errorMsg = '';
    if (errorMessageProviderFunc != null) {
      errorMsg = await errorMessageProviderFunc(exception);
    } else {
      errorMsg = exception.toString();
    }

    setState(errorMessage: errorMsg);
  }

  void setState({bool enabled, bool executing, String errorMessage}) {
    final newState = state.value.copyWith(
      enabled: enabled,
      executing: executing,
      errorMessage: errorMessage,
    );
    state.value = newState;
  }

  void resetState() {
    setState(enabled: true, executing: false, errorMessage: '');
  }

  void dispose() {
    errorMessageProviderFunc = null;
    state.close();
  }
}

class CommandState {
  final bool enabled;
  final bool executing;
  final String errorMessage;

  bool get hasErrorMessage => errorMessage != null && errorMessage.isNotEmpty;

  const CommandState(this.enabled, this.executing, this.errorMessage);

  CommandState copyWith({bool enabled, bool executing, String errorMessage}) {
    return CommandState(
        enabled = enabled ?? this.enabled,
        executing = executing ?? this.executing,
        errorMessage = errorMessage ?? this.errorMessage);
  }
}
