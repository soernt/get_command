part of get_command;

/// Void function with three generic parameter.
///
/// That is the command function signature for the CommandP3 class.
typedef VoidFuncWith3Parameters<P1, P2, P3> = FutureOr<void> Function(
    P1 p1, P2 p2, P3);

/// Command with three generic parameters.
class GetCommandP3<P1, P2, P3> extends _GetCommandBase {
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

  /// Executes the command function [commandFunc].
  FutureOr<void> exec(P1 p1, P2 p2, P3 p3) {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!(p1, p2, p3));
  }
}
