import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/infrastructure/metrics/metrics_service.dart' as core;
import 'load_tester.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Performance'),
            Tab(text: 'Scalability'),
            Tab(text: 'Usability'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_PerformanceTab(), _ScalabilityTab(), _UsabilityTab()],
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: core.MetricsService.instance,
      builder: (context, _) {
        final summaries = core.MetricsService.instance.summarize();
        final entries = summaries.values.toList()
          ..sort((a, b) => a.op.compareTo(b.op));
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: entries
                    .map(
                      (s) => _SummaryCard(
                        title: s.op,
                        subtitle:
                            'count: ${s.count}  p50: ${s.p50}ms  p95: ${s.p95}ms  errors: ${(s.errorRate * 100).toStringAsFixed(1)}% ',
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _RecentEventsTable(
                  events: core.MetricsService.instance.events
                      .take(200)
                      .toList()
                      .reversed
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RecentEventsTable extends StatelessWidget {
  const _RecentEventsTable({required this.events});
  final List<core.MetricEvent> events;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('HH:mm:ss.SSS');
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Op')),
              DataColumn(label: Text('Duration (ms)')),
              DataColumn(label: Text('Success')),
              DataColumn(label: Text('Error')),
            ],
            rows: events
                .map(
                  (e) => DataRow(
                    cells: [
                      DataCell(Text(df.format(e.at))),
                      DataCell(Text(e.op)),
                      DataCell(Text('${e.durationMs}')),
                      DataCell(
                        Icon(
                          e.success ? Icons.check_circle : Icons.cancel,
                          color: e.success ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                      DataCell(Text(e.error ?? '')),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ScalabilityTab extends StatelessWidget {
  const _ScalabilityTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Load test starting...')),
                  );
                  // ignore: use_build_context_synchronously
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final loadTester = LoadTester();
                    final result = await loadTester.run();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Load test done: ${result.summaryText}'),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Load test failed: $e')),
                    );
                  }
                },
                child: const Text('Run default load test'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Running Firestore emulator test...'),
                      ),
                    );
                    final emu = FirestoreEmulatorLoadTester();
                    final result = await emu.run();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Emulator test done: ${result.summaryText}',
                        ),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Emulator test failed: $e')),
                    );
                  }
                },
                child: const Text('Run Firestore emulator test'),
              ),
              const SizedBox(width: 12),
              Text('Recent ops: ${core.MetricsService.instance.events.length}'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Results will reflect in Performance tab cards and table.',
          ),
        ],
      ),
    );
  }
}

class _UsabilityTab extends StatefulWidget {
  const _UsabilityTab();

  @override
  State<_UsabilityTab> createState() => _UsabilityTabState();
}

class _UsabilityTabState extends State<_UsabilityTab> {
  final List<int> _answers = List<int>.filled(10, 3);
  int _nps = 7;
  final TextEditingController _comments = TextEditingController();

  @override
  void dispose() {
    _comments.dispose();
    super.dispose();
  }

  double _susScore() {
    double sum = 0;
    for (int i = 0; i < _answers.length; i++) {
      final a = _answers[i];
      sum += (i % 2 == 0) ? (a - 1) : (5 - a);
    }
    return sum * 2.5;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('System Usability Scale (SUS)'),
          const SizedBox(height: 8),
          for (int i = 0; i < 10; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('Q${i + 1}')),
                  DropdownButton<int>(
                    value: _answers[i],
                    items: const [1, 2, 3, 4, 5]
                        .map(
                          (v) => DropdownMenuItem<int>(
                            value: v,
                            child: Text('$v'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _answers[i] = v ?? 3),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('NPS (0-10):'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _nps,
                items: List.generate(11, (i) => i)
                    .map(
                      (v) => DropdownMenuItem<int>(value: v, child: Text('$v')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _nps = v ?? 7),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comments,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Comments'),
          ),
          const SizedBox(height: 12),
          Text('SUS score: ${_susScore().toStringAsFixed(1)}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback recorded (in-memory).')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
