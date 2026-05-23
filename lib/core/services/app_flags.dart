class AppFlags {
  AppFlags._();

  static DateTime? _suppressLogoutUntil;

  /// Suppresses the 401→logout event for [duration].
  /// Use this before background reload calls that follow a successful mutation,
  /// so a transient server hiccup doesn't kick the user out mid-session.
  static void suppressLogout(Duration duration) {
    _suppressLogoutUntil = DateTime.now().add(duration);
  }

  static bool get isLogoutSuppressed {
    final until = _suppressLogoutUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }
}
