import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../core/models.dart';
import '../../shared/widgets/markdown_card.dart';

class BaziScreen extends ConsumerStatefulWidget {
  const BaziScreen({super.key});

  @override
  ConsumerState<BaziScreen> createState() => _BaziScreenState();
}

class _BaziScreenState extends ConsumerState<BaziScreen> {
  final _api = ApiClient();
  int _year = 1990, _month = 1, _day = 1, _hour = 12, _minute = 0;
  int _gender = 1; // 1=男 0=女
  String _name = '';

  Map<String, dynamic>? _baziData;
  bool _loading = false;
  String? _deepResult;
  String? _analyzeResult;
  bool _aiLoading = false;
  String? _error;

  Future<void> _calculate() async {
    setState(() { _loading = true; _error = null; _deepResult = null; _analyzeResult = null; });
    try {
      final input = BaziInput(
        year: _year, month: _month, day: _day,
        hour: _hour, minute: _minute, gender: _gender,
      );
      final res = await _api.post(ApiEndpoints.baziCalculate, data: input.toJson());
      setState(() => _baziData = res.data as Map<String, dynamic>);
    } catch (e) {
      setState(() => _error = '排盘失败: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deepAnalysis() async {
    if (_baziData == null) return;
    setState(() => _aiLoading = true);
    try {
      final input = BaziInput(
        year: _year, month: _month, day: _day,
        hour: _hour, minute: _minute, gender: _gender,
      );
      final res = await _api.post(ApiEndpoints.deepAnalysis, data: input.toJson());
      setState(() => _deepResult = res.data['analysis'] as String);
    } catch (e) {
      setState(() => _error = 'AI 分析失败: $e');
    } finally {
      setState(() => _aiLoading = false);
    }
  }

  Future<void> _analyze() async {
    if (_baziData == null) return;
    setState(() => _aiLoading = true);
    try {
      final input = BaziInput(
        year: _year, month: _month, day: _day,
        hour: _hour, minute: _minute, gender: _gender,
      );
      final res = await _api.post(ApiEndpoints.analyze, data: input.toJson());
      setState(() => _analyzeResult = res.data['analysis'] as String);
    } catch (e) {
      setState(() => _error = 'AI 分析失败: $e');
    } finally {
      setState(() => _aiLoading = false);
    }
  }

  Future<void> _savePrediction(String type, String title, String content) async {
    try {
      final raw = _baziData?['raw_string'] ?? '';
      await _api.post(ApiEndpoints.predictions, data: PredictionInput(
        type: type, title: title, content: content, detail: raw,
      ).toJson());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存到历史记录')));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('八字排盘')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 姓名
          TextField(
            decoration: const InputDecoration(labelText: '姓名', border: OutlineInputBorder()),
            onChanged: (v) => _name = v,
          ),
          const SizedBox(height: 12),

          // 性别
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('男')),
              ButtonSegment(value: 0, label: Text('女')),
            ],
            selected: {_gender},
            onSelectionChanged: (v) => setState(() => _gender = v.first),
          ),
          const SizedBox(height: 16),

          // 日期时间
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _numField('年', _year, 1900, 2100, (v) => _year = v),
              _numField('月', _month, 1, 12, (v) => _month = v),
              _numField('日', _day, 1, 31, (v) => _day = v),
              _numField('时', _hour, 0, 23, (v) => _hour = v),
              _numField('分', _minute, 0, 59, (v) => _minute = v),
            ],
          ),
          const SizedBox(height: 16),

          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),

          // 排盘按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _loading ? null : _calculate,
              child: _loading
                  ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  : const Text('排盘'),
            ),
          ),

          // 排盘结果
          if (_baziData != null) ...[
            const SizedBox(height: 16),
            _buildResult(),
          ],
        ],
      ),
    );
  }

  Widget _numField(String label, int value, int min, int max, ValueChanged<int> onChange) {
    return SizedBox(
      width: 72,
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null && n >= min && n <= max) onChange(n);
        },
      ),
    );
  }

  Widget _buildResult() {
    final b = _baziData!;
    final pillars = b['pillars'] as Map<String, dynamic>;
    final shiShen = b['shi_shen'] as Map<String, dynamic>;
    final naYin = b['na_yin'] as Map<String, dynamic>;
    final hideGan = b['hide_gan'] as Map<String, dynamic>;
    final wuXing = b['wu_xing'] as Map<String, dynamic>;

    final nameStr = _name.isNotEmpty ? _name : '未命名';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // 基本信息
      Text('基本信息', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4),
      Text('性别：${b['gender']}   公历：${b['solar_time']}'),
      Text('真太阳时：${b['true_solar_time']}   农历：${b['lunar_date']}'),
      const Divider(height: 24),

      // 四柱八字表格
      Text('四柱八字', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Table(
        border: TableBorder.all(),
        columnWidths: const {0: FixedColumnWidth(48), 1: FlexColumnWidth(), 2: FlexColumnWidth(), 3: FlexColumnWidth()},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            _cell('柱', bold: true), _cell('干支', bold: true), _cell('十神', bold: true), _cell('纳音', bold: true),
          ]),
          for (final entry in {'年柱': 'year', '月柱': 'month', '日柱': 'day', '时柱': 'time'}.entries)
            TableRow(children: [
              _cell(entry.key),
              _cell(pillars[entry.value] ?? ''),
              _cell(shiShen[entry.value] ?? ''),
              _cell(naYin[entry.value] ?? ''),
            ]),
        ],
      ),
      const Divider(height: 24),

      // 藏干
      Text('藏干', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4),
      for (final entry in {'年柱': 'year', '月柱': 'month', '日柱': 'day', '时柱': 'time'}.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text('${entry.key}：${(hideGan[entry.value] as List).join(' ')}'),
        ),
      const Divider(height: 24),

      // 五行
      Text('五行分布', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4),
      for (final entry in {'年柱': 'year', '月柱': 'month', '日柱': 'day', '时柱': 'time'}.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text('${entry.key}：${wuXing[entry.value]}'),
        ),
      const Divider(height: 24),

      // AI 深度分析按钮
      Text('深度分析', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: _aiLoading ? null : _deepAnalysis,
          child: _aiLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text('AI 深度分析'),
        ),
      ),
      if (_deepResult != null) ...[
        MarkdownCard(content: _deepResult!),
        TextButton(
          onPressed: () => _savePrediction('deep_analysis', '$nameStr-深度分析', _deepResult!),
          child: const Text('保存深度分析结果'),
        ),
      ],
      const Divider(height: 24),

      // AI 命理分析按钮
      Text('AI 命理分析', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: _aiLoading ? null : _analyze,
          child: const Text('AI 命理分析'),
        ),
      ),
      if (_analyzeResult != null) ...[
        MarkdownCard(content: _analyzeResult!),
        TextButton(
          onPressed: () => _savePrediction('analyze', '$nameStr-命理分析', _analyzeResult!),
          child: const Text('保存命理分析结果'),
        ),
      ],
    ]);
  }

  static Widget _cell(String text, {bool bold = false}) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : null)),
  );
}
