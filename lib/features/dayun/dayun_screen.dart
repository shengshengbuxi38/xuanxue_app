import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../core/models.dart';
import '../../shared/widgets/markdown_card.dart';

class DayunScreen extends ConsumerStatefulWidget {
  const DayunScreen({super.key});

  @override
  ConsumerState<DayunScreen> createState() => _DayunScreenState();
}

class _DayunScreenState extends ConsumerState<DayunScreen> {
  final _api = ApiClient();
  int _year = 1990, _month = 1, _day = 1, _hour = 12, _minute = 0;
  int _gender = 1;

  String? _result;
  bool _loading = false;

  Future<void> _predict() async {
    setState(() => _loading = true);
    try {
      final input = BaziInput(year: _year, month: _month, day: _day, hour: _hour, minute: _minute, gender: _gender);
      final res = await _api.post(ApiEndpoints.predictEvents, data: input.toJson());
      setState(() => _result = res.data['analysis'] as String);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('预测失败: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('大运流年')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [ButtonSegment(value: 1, label: Text('男')), ButtonSegment(value: 0, label: Text('女'))],
            selected: {_gender},
            onSelectionChanged: (v) => setState(() => _gender = v.first),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _f('年', _year, 1900, 2100, (v) => _year = v),
            _f('月', _month, 1, 12, (v) => _month = v),
            _f('日', _day, 1, 31, (v) => _day = v),
            _f('时', _hour, 0, 23, (v) => _hour = v),
            _f('分', _minute, 0, 59, (v) => _minute = v),
          ]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48, child: FilledButton(
            onPressed: _loading ? null : _predict,
            child: _loading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('AI 大运流年分析'),
          )),
          if (_result != null) MarkdownCard(content: _result!),
        ],
      ),
    );
  }

  Widget _f(String l, int v, int mn, int mx, ValueChanged<int> c) => SizedBox(
    width: 72,
    child: TextFormField(
      initialValue: v.toString(),
      decoration: InputDecoration(labelText: l, border: const OutlineInputBorder(), isDense: true),
      keyboardType: TextInputType.number,
      onChanged: (s) { final n = int.tryParse(s); if (n != null && n >= mn && n <= mx) c(n); },
    ),
  );
}
