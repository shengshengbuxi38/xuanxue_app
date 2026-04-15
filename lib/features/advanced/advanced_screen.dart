import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';
import '../../core/models.dart';
import '../../shared/widgets/markdown_card.dart';

class AdvancedScreen extends ConsumerStatefulWidget {
  const AdvancedScreen({super.key});

  @override
  ConsumerState<AdvancedScreen> createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends ConsumerState<AdvancedScreen> {
  final _api = ApiClient();
  // 甲方
  int _y1 = 1990, _m1 = 1, _d1 = 1, _h1 = 12, _mi1 = 0; int _g1 = 1;
  // 乙方
  int _y2 = 1995, _m2 = 6, _d2 = 15, _h2 = 10, _mi2 = 0; int _g2 = 0;
  String _matchType = '婚配';

  // 起卦
  final _numbersController = TextEditingController();
  final _questionController = TextEditingController();

  String? _matchResult;
  String? _divResult;
  bool _loading = false;

  final _matchTypes = ['亲子', '兄弟姐妹', '上下级', '平级', '朋友', '合作伙伴', '投资对象', '客户/供应商', '师生', '同学'];

  Future<void> _doMatch() async {
    setState(() => _loading = true);
    try {
      final input = BaziMatchInput(
        person1: BaziInput(year: _y1, month: _m1, day: _d1, hour: _h1, minute: _mi1, gender: _g1),
        person2: BaziInput(year: _y2, month: _m2, day: _d2, hour: _h2, minute: _mi2, gender: _g2),
        matchType: _matchType,
      );
      final res = await _api.post(ApiEndpoints.match, data: input.toJson());
      setState(() => _matchResult = res.data['analysis'] as String);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('匹配失败: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _doDivination() async {
    final numbers = _numbersController.text.trim();
    if (numbers.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入数字'))); return; }
    setState(() => _loading = true);
    try {
      final input = DivinationInput(numbers: numbers, question: _questionController.text.trim());
      final res = await _api.post(ApiEndpoints.divination, data: input.toJson());
      setState(() => _divResult = res.data['analysis'] as String);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('起卦失败: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('高级功能'), bottom: const TabBar(tabs: [Tab(text: '八字匹配'), Tab(text: '数字起卦')])),
        body: TabBarView(children: [_buildMatch(), _buildDivination()]),
      ),
    );
  }

  Widget _buildMatch() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      DropdownButtonFormField<String>(initialValue: _matchType, decoration: const InputDecoration(labelText: '匹配类型'),
        items: _matchTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _matchType = v ?? '婚配')),
      const Text('甲方', style: TextStyle(fontWeight: FontWeight.bold)),
      _row(_g1, _y1, _m1, _d1, _h1, _mi1, (g, y, m, d, h, mi) { _g1 = g; _y1 = y; _m1 = m; _d1 = d; _h1 = h; _mi1 = mi; }),
      const Divider(),
      const Text('乙方', style: TextStyle(fontWeight: FontWeight.bold)),
      _row(_g2, _y2, _m2, _d2, _h2, _mi2, (g, y, m, d, h, mi) { _g2 = g; _y2 = y; _m2 = m; _d2 = d; _h2 = h; _mi2 = mi; }),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 48, child: FilledButton(
        onPressed: _loading ? null : _doMatch,
        child: _loading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('开始合盘分析'),
      )),
      if (_matchResult != null) MarkdownCard(content: _matchResult!),
    ],
  );

  Widget _buildDivination() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TextField(controller: _numbersController, decoration: const InputDecoration(labelText: '数字（逗号分隔）', hintText: '例：3, 8, 6', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _questionController, decoration: const InputDecoration(labelText: '想问什么？（可选）', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 48, child: FilledButton(
        onPressed: _loading ? null : _doDivination,
        child: _loading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('起卦解卦'),
      )),
      if (_divResult != null) MarkdownCard(content: _divResult!),
    ],
  );

  Widget _row(int g, int y, int m, int d, int h, int mi, void Function(int, int, int, int, int, int) set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: [
        SegmentedButton<int>(
          segments: const [ButtonSegment(value: 1, label: Text('男')), ButtonSegment(value: 0, label: Text('女'))],
          selected: {g},
          onSelectionChanged: (v) => set(v.first, y, m, d, h, mi),
        ),
        const SizedBox(height: 4),
        Wrap(spacing: 4, runSpacing: 4, children: [
          _nf('年', y, (v) => set(g, v, m, d, h, mi)),
          _nf('月', m, (v) => set(g, y, v, d, h, mi)),
          _nf('日', d, (v) => set(g, y, m, v, h, mi)),
          _nf('时', h, (v) => set(g, y, m, d, v, mi)),
          _nf('分', mi, (v) => set(g, y, m, d, h, v)),
        ]),
      ]),
    );
  }

  Widget _nf(String l, int v, ValueChanged<int> c) => SizedBox(
    width: 64, child: TextFormField(
      initialValue: v.toString(),
      decoration: InputDecoration(labelText: l, border: const OutlineInputBorder(), isDense: true),
      keyboardType: TextInputType.number,
      onChanged: (s) { final n = int.tryParse(s); if (n != null) c(n); },
    ),
  );
}
