abstract final class DurationTokens {
  DurationTokens._();

  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);
  static const Duration slower = Duration(milliseconds: 300);
  static const Duration deliberate = Duration(milliseconds: 400);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration xl = Duration(milliseconds: 700);
  static const Duration xxl = Duration(milliseconds: 1000);
}
