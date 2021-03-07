part of get_command;

/// Error message callback. The result string will be used as the error message.
///
/// That is the function signature for errorMessageProviderFunc.
typedef ErrorMessageProvider = FutureOr<String> Function(Exception exception);

/// The Command base class
abstract class _GetCommandBase extends Rx<CommandState> {
  /// The current state of the command.
  CommandState get state => value ?? CommandState.defaultState();

  set _state(CommandState stateValue) {
    value = stateValue;
  }

  /// A optional developer provided callback function that translates
  /// an exception to an error message.
  ///
  /// When a exceptions is thrown by the commandFunc, then
  /// this function will be called to get the state.errorMessage
  ErrorMessageProvider? errorMessageProviderFunc;

  /// Is the command enabled.
  bool get enabled => state.enabled;

  /// Is the commandFunc currently executed.
  bool get executing => state.executing;

  /// Can the user execute the commandFunc.
  bool get canBeExecuted => state.canBeExecuted;

  /// Does the last call to of the commandFunc results to an errorMessage.
  bool get hasErrorMessage => state.hasErrorMessage;

  /// An error message
  String get errorMessage => state.errorMessage;

  _GetCommandBase({bool enabled = true, bool executing = false}) {
    setState(
      enabled: enabled,
      executing: executing,
    );
  }

  FutureOr<void> _doExecute(
      FutureOr<void> Function() internalCommandFunc) async {
    if (!state.enabled) {
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
    _state = state.copyWith(
      enabled: enabled,
      executing: executing,
      errorMessage: errorMessage,
    );
  }

  /// Resets the state to enabled, not executing without an errorMessage.
  void resetState() {
    setState(enabled: true, executing: false, errorMessage: '');
  }

  /// Releases all resources.
  @mustCallSuper
  void dispose() {
    close();
    errorMessageProviderFunc = null;
  }
}
