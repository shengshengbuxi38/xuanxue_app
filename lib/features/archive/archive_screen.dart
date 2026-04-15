import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../core/models.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  final _api = ApiClient();
  List<Record> _records = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await _api.get(ApiEndpoints.records);
      final list = (res.data['records'] as List).map((e) => Record.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _records = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _api.delete('${ApiEndpoints.records}/$id');
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('八字档案库')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('暂无记录，请在排盘时输入姓名保存'))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, i) {
                    final r = _records[i];
                    return ListTile(
                      title: Text(r.label),
                      subtitle: Text('保存：${r.createdAt.substring(0, 16)}'),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(r.id)),
                    );
                  },
                ),
    );
  }
}
