import 'dart:async';

class AuthEvents {
  static final _unauthorizedController = StreamController<void>.broadcast();
  static Stream<void> get onUnauthorized => _unauthorizedController.stream;
  static void notifyUnauthorized() => _unauthorizedController.add(null);
}
