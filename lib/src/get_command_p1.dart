part of get_command;

/// Void function with one generic parameter.
///
/// That is the command function signature for the CommandP1 class.
typedef VoidFuncWith1Parameter<P1> = FutureOr<void> Function(P1 p1);

/// Command with one generic parameter.
class GetCommandP1<P1> extends _GetCommandBase {
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
  FutureOr<void> exec(P1 p1) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!(p1));
  }
}
