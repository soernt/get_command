library get_command;

import 'dart:async';
import 'package:get/get_rx/get_rx.dart';

/// Void function without any parameters.
///
/// That is the command function signature for the Command class.
typedef VoidFunc = FutureOr<void> Function();

/// Void function with one generic parameter.
///
/// That is the command function signature for the CommandP1 class.
typedef VoidFuncWith1Parameter<P1> = FutureOr<void> Function(P1 p1);

/// Void function with two generic parameter.
///
/// That is the command function signature for the CommandP2 class.
typedef VoidFuncWith2Parameters<P1, P2> = FutureOr<void> Function(P1 p1, P2 p2);

/// Void function with three generic parameter.
///
/// That is the command function signature for the CommandP3 class.
typedef VoidFuncWith3Parameters<P1, P2, P3> = FutureOr<void> Function(
    P1 p1, P2 p2, P3);

/// Error message callback. The result string will be used as the error message.
///
/// That is the function signature for errorMessageProviderFunc.
typedef ErrorMessageProvider = FutureOr<String> Function(Exception exception);

/// Command with three generic parameters.
class GetCommandP3<P1, P2, P3> extends _CommandBase {
  /// The developer provided function that should be executed.
  VoidFuncWith3Parameters<P1, P2, P3>? commandFunc;

  /// Creates an instance.
  ///
  /// Provide [enabled] and [executing] for the initial state.
  /// Use the [setState] function to manual adjust the state
  GetCommandP3({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  /// Releases all resources.
  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  /// A Command is a callable class.
  ///
  /// You can use Command() instead of Command.commandFunc() to execute the
  /// command function.
  FutureOr<void> call(P1 p1, P2 p2, P3 p3) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!(p1, p2, p3));
  }
}

/// Command with two generic parameters.
class GetCommandP2<P1, P2> extends _CommandBase {
  /// The developer provided function that should be executed.
  VoidFuncWith2Parameters<P1, P2>? commandFunc;

  /// Creates an instance.
  ///
  /// Provide [enabled] and [executing] for the initial state.
  /// Use the [setState] function to manual adjust the state.
  GetCommandP2({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  /// Releases all resources.
  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  /// A Command is a callable class.
  ///
  /// You can use Command() instead of Command.commandFunc() to execute the
  /// command function.
  FutureOr<void> call(P1 p1, P2 p2) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!(p1, p2));
  }
}

/// Command with one generic parameter.
class GetCommandP1<P1> extends _CommandBase {
  /// The developer provided function that should be executed.
  VoidFuncWith1Parameter<P1>? commandFunc;

  /// Creates an instance.
  ///
  /// Provide [enabled] and [executing] for the initial state.
  /// Use the [setState] function to manual adjust the state.
  GetCommandP1({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  /// Releases all resources.
  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  /// A Command is a callable class.
  ///
  /// You can use Command() instead of Command.commandFunc() to execute the
  /// command function.
  FutureOr<void> call(P1 p1) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!(p1));
  }
}

/// Command with without any parameters..
class GetCommand extends _CommandBase {
  /// The developer provided function that should be executed.
  VoidFunc? commandFunc;

  /// Creates an instance.
  ///
  /// Provide [enabled] and [executing] for the initial state.
  /// Use the [setState] function to manual adjust the state.
  GetCommand({bool enabled = true, bool executing = false})
      : super(enabled: enabled, executing: executing);

  /// Releases all resources.
  @override
  void dispose() {
    commandFunc = null;
    super.dispose();
  }

  /// A Command is a callable class.
  ///
  /// You can use Command() instead of Command.commandFunc() to execute the
  /// command function.
  FutureOr<void> call() {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!());
  }
}

/// The Command base class
abstract class _CommandBase {
  /// The current state of the command.
  final Rx<CommandState> state;

  /// A optional developer provided callback function that translates
  /// an exception to an error message.
  ///
  /// When a exceptions is thrown by the commandFunc, then
  /// this function will be called to get the state.errorMessage
  ErrorMessageProvider? errorMessageProviderFunc;

  /// Is the command enabled.
  bool get enabled => state.value?.enabled ?? false;

  /// Is the commandFunc currently executed.
  bool get executing => state.value?.executing ?? false;

  /// Can the user execute the commandFunc.
  bool get canBeExecuted => state.value?.canBeExecuted ?? false;

  /// Does the last call to of the commandFunc throws an error.
  bool get hasError => state.value?.hasErrorMessage ?? false;

  /// An error message
  String get errorMessage => state.value?.errorMessage ?? '';

  _CommandBase({bool enabled = true, bool executing = false})
      : state = CommandState(enabled, executing, '').obs;

  FutureOr<void> _doExecute(
      FutureOr<void> Function() internalCommandFunc) async {

    if (!(state.value?.enabled ?? false)) {
      return null;
    }

    setState(executing: true, errorMessage: '');
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
      errorMsg = await errorMessageProviderFunc!(exception);
    } else {
      errorMsg = exception.toString();
    }

    setState(errorMessage: errorMsg);
  }

  /// Sets the current state of the command.
  void setState({bool? enabled, bool? executing, String? errorMessage}) {
    final newState = state.value?.copyWith(
      enabled: enabled,
      executing: executing,
      errorMessage: errorMessage,
    );
    state.value = newState;
  }

  /// Resets the state to enabled, not executing without an errorMessage.
  void resetState() {
    setState(enabled: true, executing: false, errorMessage: '');
  }

  /// Releases all resources.
  void dispose() {
    errorMessageProviderFunc = null;
    state.close();
  }
}

/// Represents the current state of a command.
class CommandState {
  /// Is the command enabled
  final bool enabled;

  /// Is the command currently executed
  final bool executing;

  /// Error message of the last execution.
  final String errorMessage;

  /// Can the user execute the commandFunc.
  bool get canBeExecuted => enabled && !executing;

  /// Is there an [errorMessage]
  bool get hasErrorMessage => errorMessage.isNotEmpty;

  const CommandState(this.enabled, this.executing, this.errorMessage);

  /// Standard copyWith(...) function.
  CommandState copyWith({bool? enabled, bool? executing, String? errorMessage}) {
    return CommandState(
        enabled = enabled ?? this.enabled,
        executing = executing ?? this.executing,
        errorMessage = errorMessage ?? this.errorMessage);
  }
}
