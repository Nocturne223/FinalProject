import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Metric event captured for an operation.
class MetricEvent {
  MetricEvent({
    required this.op,
    required this.durationMs,
    required this.success,
    required this.at,
    this.error,
    this.payloadSize,
  });

  final String op;
  final int durationMs;
  final bool success;
  final DateTime at;
  final String? error;
  final int? payloadSize;
}

/// Aggregated summary for a metric operation.
class MetricSummary {
  MetricSummary({
    required this.op,
    required this.count,
    required this.p50,
    required this.p95,
    required this.errorRate,
  });

  final String op;
  final int count;
  final int p50;
  final int p95;
  final double errorRate; // 0..1
}

/// Central metrics recorder. Keeps in-memory events and notifies listeners.
class MetricsService extends ChangeNotifier {
  MetricsService._();

  static final MetricsService instance = MetricsService._();

  final List<MetricEvent> _events = <MetricEvent>[];

  UnmodifiableListView<MetricEvent> get events => UnmodifiableListView(_events);

  void recordSuccess(String op, int durationMs, {int? payloadSize}) {
    _events.add(
      MetricEvent(
        op: op,
        durationMs: durationMs,
        success: true,
        at: DateTime.now(),
        payloadSize: payloadSize,
      ),
    );
    notifyListeners();
  }

  void recordError(String op, int durationMs, String error) {
    _events.add(
      MetricEvent(
        op: op,
        durationMs: durationMs,
        success: false,
        at: DateTime.now(),
        error: error,
      ),
    );
    notifyListeners();
  }

  void clear() {
    _events.clear();
    notifyListeners();
  }

  /// Returns summaries per operation for current in-memory events.
  Map<String, MetricSummary> summarize() {
    final Map<String, List<MetricEvent>> byOp = <String, List<MetricEvent>>{};
    for (final e in _events) {
      byOp.putIfAbsent(e.op, () => <MetricEvent>[]).add(e);
    }
    final Map<String, MetricSummary> out = <String, MetricSummary>{};
    byOp.forEach((op, events) {
      final List<int> durations =
          events.where((e) => e.success).map((e) => e.durationMs).toList()
            ..sort();
      final int count = events.length;
      final int errors = events.where((e) => !e.success).length;
      final int p50 = _percentile(durations, 0.50);
      final int p95 = _percentile(durations, 0.95);
      final double errorRate = count == 0 ? 0 : errors / count;
      out[op] = MetricSummary(
        op: op,
        count: count,
        p50: p50,
        p95: p95,
        errorRate: errorRate,
      );
    });
    return out;
  }

  int _percentile(List<int> sortedDurations, double p) {
    if (sortedDurations.isEmpty) return 0;
    final double rank = p * (sortedDurations.length - 1);
    final int lower = rank.floor();
    final int upper = rank.ceil();
    if (lower == upper) return sortedDurations[lower];
    final double weight = rank - lower;
    return (sortedDurations[lower] * (1 - weight) +
            sortedDurations[upper] * weight)
        .round();
  }
}

/// Helper to measure an async operation and record success/error.
Future<T> measure<T>(String op, Future<T> Function() action) async {
  final Stopwatch sw = Stopwatch()..start();
  try {
    final T result = await action();
    sw.stop();
    MetricsService.instance.recordSuccess(op, sw.elapsedMilliseconds);
    return result;
  } catch (e) {
    sw.stop();
    MetricsService.instance.recordError(
      op,
      sw.elapsedMilliseconds,
      e.toString(),
    );
    rethrow;
  }
}
