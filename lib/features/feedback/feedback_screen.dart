import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _api = ApiClient();
  String _category = 'Bug反馈';
  final _contentController = TextEditingController();

  final _categories = ['Bug反馈', '功能建议', '内容纠错', '体验优化', '其他'];

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入反馈内容'))); return; }
    try {
      await _api.post(ApiEndpoints.feedback, data: {'category': _category, 'content': content});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('感谢您的反馈！')));
      _contentController.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('提交失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户反馈')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(initialValue: _category, decoration: const InputDecoration(labelText: '反馈类型', border: OutlineInputBorder()),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Bug反馈')),
          const SizedBox(height: 12),
          TextField(controller: _contentController, maxLines: 5, decoration: const InputDecoration(labelText: '反馈内容', hintText: '请详细描述...', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: _submit, child: const Text('提交反馈'))),
        ],
      ),
    );
  }
}
