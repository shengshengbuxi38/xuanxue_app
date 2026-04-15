import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../core/models.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _api = ApiClient();
  List<PredictionRecord> _records = [];
  String? _filterType;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await _api.get(ApiEndpoints.predictions, queryParams: _filterType != null ? {'type': _filterType} : null);
      final list = (res.data['records'] as List).map((e) => PredictionRecord.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _records = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    try { await _api.delete('${ApiEndpoints.predictions}/$id'); _load(); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButtonFormField<String?>(
            initialValue: _filterType,
            decoration: const InputDecoration(labelText: '类型筛选', border: OutlineInputBorder(), isDense: true),
            items: [const DropdownMenuItem(value: null, child: Text('全部')),
              ...predictionTypeLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
            ],
            onChanged: (v) { setState(() => _filterType = v); _load(); },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _records.isEmpty
                  ? const Center(child: Text('暂无记录'))
                  : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, i) {
                        final r = _records[i];
                        final label = predictionTypeLabels[r.type] ?? r.type;
                        return ExpansionTile(
                          title: Text('[$label] ${r.title}'),
                          subtitle: Text(r.createdAt.substring(0, 16)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: MarkdownBody(data: r.content, selectable: true),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _delete(r.id),
                                child: const Text('删除', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
