part of get_command;

/// Void function with two generic parameter.
///
/// That is the command function signature for the CommandP2 class.
typedef VoidFuncWith2Parameters<P1, P2> = FutureOr<void> Function(P1 p1, P2 p2);

/// Command with two generic parameters.
class GetCommandP2<P1, P2> extends _GetCommandBase {
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
  FutureOr<void> exec(P1 p1, P2 p2) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!(p1, p2));
  }
}
