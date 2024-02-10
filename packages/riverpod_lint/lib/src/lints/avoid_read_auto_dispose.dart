import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:riverpod_analyzer_utils/riverpod_analyzer_utils.dart';

import '../riverpod_custom_lint.dart';

class AvoidReadAutoDispose extends RiverpodLintRule {
  const AvoidReadAutoDispose() : super(code: _code);

  static const _code = LintCode(
    name: 'riverpod_avoid_read_auto_dispose',
    problemMessage: 'Avoid using ref.read on an autoDispose provider',
    correctionMessage: '''
Instead use:
  final listener = ref.listen({0}, (_, __){});
  final currentValue = listener.read();
Then dispose of the listener when you no longer need the autoDispose provider to be kept alive.''',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    riverpodRegistry(context).addRefReadInvocation((read) {
      final provider = read.provider.providerElement;

      if (provider is GeneratorProviderDeclarationElement &&
          provider.isAutoDispose) {
        reporter.reportErrorForNode(
          _code,
          read.node,
          [read.provider.provider!],
        );
      }
    });
  }
}
