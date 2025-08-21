import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/infrastructure/metrics/metrics_service.dart';
import '../../core/infrastructure/firebase_emulator.dart';

/// Very lightweight synthetic load tester that performs measured operations.
class LoadTester {
  Future<LoadTestResult> run({int reads = 50, int writes = 10}) async {
    final Stopwatch total = Stopwatch()..start();
    final Random rng = Random();

    // Simulate reads
    for (int i = 0; i < reads; i++) {
      await measure('synthetic.read', () async {
        await Future<void>.delayed(
          Duration(milliseconds: 50 + rng.nextInt(100)),
        );
      });
    }

    // Simulate writes
    for (int i = 0; i < writes; i++) {
      await measure('synthetic.write', () async {
        await Future<void>.delayed(
          Duration(milliseconds: 80 + rng.nextInt(120)),
        );
      });
    }

    total.stop();

    final summaries = MetricsService.instance.summarize();
    final readP95 = summaries['synthetic.read']?.p95 ?? 0;
    final writeP95 = summaries['synthetic.write']?.p95 ?? 0;
    return LoadTestResult(
      totalMs: total.elapsedMilliseconds,
      readP95Ms: readP95,
      writeP95Ms: writeP95,
    );
  }
}

/// Firestore-backed load tester that targets the emulator when enabled.
class FirestoreEmulatorLoadTester {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<LoadTestResult> run({int reads = 50, int writes = 10}) async {
    if (!FirebaseEmulatorConfig.usingEmulator) {
      throw StateError(
        'Firestore emulator is not configured. Run with --dart-define=USE_EMULATOR=true and start emulators.',
      );
    }

    final Stopwatch total = Stopwatch()..start();
    final Random rng = Random();
    final CollectionReference<Map<String, dynamic>> coll = _db.collection(
      'evaluation_products',
    );

    // Seed a small dataset if empty
    final existing = await coll.limit(1).get();
    if (existing.size == 0) {
      for (int i = 0; i < 50; i++) {
        await measure(
          'emul.write.seed',
          () => coll.add({
            'name': 'Item ${i + 1}',
            'price': rng.nextInt(1000) / 100.0,
            'stock': rng.nextInt(500),
            'ts': FieldValue.serverTimestamp(),
          }),
        );
      }
    }

    // Reads
    for (int i = 0; i < reads; i++) {
      await measure('emul.read', () async {
        final snap = await coll.orderBy('name').limit(20).get();
        // Touch data to simulate decode cost
        int c = 0;
        for (final d in snap.docs) {
          c += (d.data()['stock'] as int? ?? 0);
        }
        if (c < 0) {
          throw Exception('impossible');
        }
      });
    }

    // Writes
    for (int i = 0; i < writes; i++) {
      await measure('emul.write', () async {
        await coll.add({
          'name': 'New ${DateTime.now().millisecondsSinceEpoch}',
          'price': rng.nextInt(1000) / 100.0,
          'stock': rng.nextInt(500),
          'ts': FieldValue.serverTimestamp(),
        });
      });
    }

    total.stop();
    final summaries = MetricsService.instance.summarize();
    final readP95 = summaries['emul.read']?.p95 ?? 0;
    final writeP95 = summaries['emul.write']?.p95 ?? 0;
    return LoadTestResult(
      totalMs: total.elapsedMilliseconds,
      readP95Ms: readP95,
      writeP95Ms: writeP95,
    );
  }
}

class LoadTestResult {
  LoadTestResult({
    required this.totalMs,
    required this.readP95Ms,
    required this.writeP95Ms,
  });
  final int totalMs;
  final int readP95Ms;
  final int writeP95Ms;

  String get summaryText =>
      'total ${totalMs}ms, read p95 ${readP95Ms}ms, write p95 ${writeP95Ms}ms';
}
