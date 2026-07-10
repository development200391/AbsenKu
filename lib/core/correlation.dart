import 'dart:math';

/// Tracks the correlation id used on the most recent outgoing API request, so
/// error reports that aren't tied to any single HTTP call can still reference
/// "the last thing this app talked to the server about".
class CorrelationContext {
  CorrelationContext._();

  static String? lastRequestId;

  static String generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final random = Random();
    final suffix = List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
    return '$timestamp-$suffix';
  }
}
