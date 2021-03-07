import 'package:flutter_test/flutter_test.dart';

import '../lib/get_command.dart';

void main() {
  group('Commands', () {
    group('Command', () {
      group('Construction', () {
        test(
            'when no parameters are given, then state is '
            '* enabled'
            '* not executing '
            '* canBeExecuted'
            '* no errors', () {
          // Act
          final cmd = GetCommand();

          // Assert
          expect(cmd.enabled, true);
          expect(cmd.executing, false);
          expect(cmd.canBeExecuted, true);
          expect(cmd.errorMessage, '');
          expect(cmd.hasErrorMessage, false);
        });

        test(
            'when enabled parameter is given, '
            'then state enabled should have expected value', () {
          // Arrange
          final expectedEnabledValue = false;

          // Act
          final cmd = GetCommand(enabled: expectedEnabledValue);

          // Assert
          expect(cmd.enabled, expectedEnabledValue);
        });

        test(
            'when executing parameter is given, '
            'then state executing should have expected value', () {
          // Arrange
          final expectedExecutingValue = true;

          // Act
          final cmd = GetCommand(executing: expectedExecutingValue);

          // Assert
          expect(cmd.executing, expectedExecutingValue);
        });
      });

      group('Calling command', () {
        test('And no command function is given, then throws AssertionError',
            () {
          // Arrange
          final cmd = GetCommand();

          // Act
          final act = () async => await cmd.exec();

          // Assert
          expect(act, throwsAssertionError);
        });

        test('And it is not enabled, then command function is not called',
            () async {
          // Arrange
          var cmdFuncCalled = false;
          final cmd = GetCommand(enabled: false)
            ..commandFunc = () => cmdFuncCalled = true;

          // Act
          await cmd.exec();

          // Assert
          expect(cmdFuncCalled, false);
        });

        test(
            'When calling, then:'
            '* executing switches from false to true and back to false',
            () async {
          // Arrange
          var events = <CommandState>[];
          final cmd = GetCommand()
            ..commandFunc = () {}
            ..listen((CommandState? state) {
              if (state != null) {
                events.add(state);
              }
            });

          events.add(cmd.value!);
          // Act
          await cmd.exec();
          await Future.delayed(Duration(microseconds: 50));

          // Assert
          expect(events.length, 3);
          expect(events[0].executing, false);
          expect(events[1].executing, true);
          expect(events[2].executing, false);
        });

        test(
            'When errorMessageProviderFunc has been provided and commandFunc throws, then:'
            '* hasError is true'
            '* errorMessageProviderFunc has been called'
            '* errorMessage is provided error Message', () async {
          // Arrange
          const expectedErrorMessage = 'error occurred';
          var errorMessageProviderFuncHasBeenCalled = false;
          final errorMessageProviderFunc = (Exception ex) {
            errorMessageProviderFuncHasBeenCalled = true;
            return expectedErrorMessage;
          };

          final cmd = GetCommand()
            ..errorMessageProviderFunc = errorMessageProviderFunc
            ..commandFunc = () => throw Exception('Some error');

          // Act
          await cmd.exec();

          // Assert
          expect(cmd.hasErrorMessage, true);
          expect(errorMessageProviderFuncHasBeenCalled, true);
          expect(cmd.errorMessage, expectedErrorMessage);
        });

        test(
            'When errorMessageProviderFunc has not been provided and commandFunc throws, then:'
            '* hasError is true'
            '* errorMessage is Exception.toString()', () async {
          // Arrange
          final exceptionToThrow = Exception('Some Error');

          final cmd = GetCommand()..commandFunc = () => throw exceptionToThrow;

          // Act
          await cmd.exec();

          // Assert
          expect(cmd.hasErrorMessage, true);
          expect(cmd.errorMessage, exceptionToThrow.toString());
        });
      });

      group('Destruction', () {
        test(
            'When dispose is called, then: '
            '* errorMessageProviderFunc is set to null'
            '* commandFunc is set to null', () {
          // Arrange
          final cmd = GetCommand();
          cmd.errorMessageProviderFunc = (Exception ex) => '';
          cmd.commandFunc = () {};

          // Act
          cmd.dispose();

          // Assert
          expect(cmd.errorMessageProviderFunc, null);
          expect(cmd.commandFunc, null);
        });
      });
    });

    group('CommandP1', () {
      test('then one parameter is passed down to commandFunc', () async {
        // Arrange
        final expectedP1Value = 'p1Value';
        String? receivedP1Value;
        final cmdFunc = (String parameterP1) {
          receivedP1Value = parameterP1;
        };
        final cmd = GetCommandP1<String>()..commandFunc = cmdFunc;

        // Act‚
        await cmd.exec(expectedP1Value);

        // Assert
        expect(receivedP1Value, expectedP1Value);
      });

      test(
          'When dispose is called, then: '
          '* errorMessageProviderFunc is set to null'
          '* commandFunc is set to null', () {
        // Arrange
        final cmd = GetCommandP1<String>();
        cmd.errorMessageProviderFunc = (Exception ex) => '';
        cmd.commandFunc = (String p1) {};

        // Act
        cmd.dispose();

        // Assert
        expect(cmd.errorMessageProviderFunc, null);
        expect(cmd.commandFunc, null);
      });
    });

    group('CommandP2', () {
      test('then two parameter are passed down to commandFunc', () async {
        // Arrange
        final expectedP1Value = 'p1Value';
        final expectedP2Value = 1;
        String? receivedP1Value;
        int? receivedP2Value;
        final cmdFunc = (String parameterP1, int parameterP2) {
          receivedP1Value = parameterP1;
          receivedP2Value = parameterP2;
        };
        final cmd = GetCommandP2<String, int>()..commandFunc = cmdFunc;

        // Act‚
        await cmd.exec(expectedP1Value, expectedP2Value);

        // Assert
        expect(receivedP1Value, expectedP1Value);
        expect(receivedP2Value, expectedP2Value);
      });

      test(
          'When dispose is called, then: '
          '* errorMessageProviderFunc is set to null'
          '* commandFunc is set to null', () {
        // Arrange
        final cmd = GetCommandP2<String, int>();
        cmd.errorMessageProviderFunc = (Exception ex) => '';
        cmd.commandFunc = (String p1, int p2) {};

        // Act
        cmd.dispose();

        // Assert
        expect(cmd.errorMessageProviderFunc, null);
        expect(cmd.commandFunc, null);
      });
    });

    group('CommandP3', () {
      test('then three parameter are passed down to commandFunc', () async {
        // Arrange
        final expectedP1Value = 'p1Value';
        final expectedP2Value = 1;
        var expectedP3Value = true;
        String? receivedP1Value;
        int? receivedP2Value;
        bool? receivedP3Value;
        final cmdFunc =
            (String parameterP1, int parameterP2, bool parameterP3) {
          receivedP1Value = parameterP1;
          receivedP2Value = parameterP2;
          receivedP3Value = parameterP3;
        };
        final cmd = GetCommandP3<String, int, bool>()
          ..commandFunc = cmdFunc;

        // Act‚
        await cmd.exec(expectedP1Value, expectedP2Value, expectedP3Value);

        // Assert
        expect(receivedP1Value, expectedP1Value);
        expect(receivedP2Value, expectedP2Value);
        expect(receivedP3Value, expectedP3Value);
      });

      test(
          'When dispose is called, then: '
          '* errorMessageProviderFunc is set to null'
          '* commandFunc is set to null', () {
        // Arrange
        final cmd = GetCommandP3<String, int, bool>();
        cmd.errorMessageProviderFunc = (Exception ex) => '';
        cmd.commandFunc = (String p1, int p2, bool p3) {};

        // Act
        cmd.dispose();

        // Assert
        expect(cmd.errorMessageProviderFunc, null);
        expect(cmd.commandFunc, null);
      });
    });
  });
}
