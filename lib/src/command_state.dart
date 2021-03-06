part of get_command;

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

  /// Create an instance with [enabled] = true, [executing] = false and [errorMessage] = ''
  factory CommandState.defaultState() {
    return const CommandState(true, false, '');
  }

  /// Standard copyWith(...) function.
  CommandState copyWith(
      {bool? enabled, bool? executing, String? errorMessage}) {
    return CommandState(
        enabled = enabled ?? this.enabled,
        executing = executing ?? this.executing,
        errorMessage = errorMessage ?? this.errorMessage);
  }
}
