part of get_command;

/// Void function without any parameters.
///
/// That is the command function signature for the Command class.
typedef VoidFunc = FutureOr<void> Function();

// Command with without any parameters..
class GetCommand extends _GetCommandBase {
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

  /// Executes the command function [commandFunc].
  FutureOr<void> exec() {
    assert(commandFunc != null);
    return _doExecute(() => commandFunc!());
  }
}
