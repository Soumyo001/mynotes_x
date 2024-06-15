import 'package:flutter/foundation.dart' show immutable;

typedef UpdateLoadingScreen = bool Function(String text);
typedef CloseLoadinScreen = bool Function();

@immutable
class LoadingController {
  final UpdateLoadingScreen updateLoadingScreen;
  final CloseLoadinScreen closeLoadinScreen;
  const LoadingController({
    required this.updateLoadingScreen,
    required this.closeLoadinScreen,
  });
}
