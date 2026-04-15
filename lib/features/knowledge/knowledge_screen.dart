import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  final _api = ApiClient();
  List _books = [];
  bool _loading = true;
  String? _bookContent;
  final _questionController = TextEditingController();
  String? _answer;
  bool _qaLoading = false;

  @override
  void initState() { super.initState(); _loadBooks(); }

  Future<void> _loadBooks() async {
    try {
      final res = await _api.get(ApiEndpoints.books);
      if (mounted) setState(() { _books = res.data['books'] as List; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openBook(String filename) async {
    try {
      final res = await _api.get('${ApiEndpoints.bookContent}/$filename');
      if (mounted) setState(() => _bookContent = res.data['content'] as String);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('加载失败')));
    }
  }

  Future<void> _ask() async {
    final q = _questionController.text.trim();
    if (q.isEmpty) return;
    setState(() => _qaLoading = true);
    try {
      final res = await _api.post(ApiEndpoints.qa, data: {'question': q});
      if (mounted) setState(() => _answer = res.data['answer'] as String);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('问答失败: $e')));
    } finally {
      if (mounted) setState(() => _qaLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('知识库'), bottom: const TabBar(tabs: [Tab(text: '书籍'), Tab(text: '问答')])),
        body: TabBarView(children: [_buildBooks(), _buildQA()]),
      ),
    );
  }

  Widget _buildBooks() {
    if (_bookContent != null) {
      return Column(children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _bookContent = null)),
        Expanded(child: Markdown(data: _bookContent!)),
      ]);
    }
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _books.length,
            itemBuilder: (context, i) {
              final b = _books[i] as Map<String, dynamic>;
              return ListTile(
                title: Text(b['title'] ?? ''),
                subtitle: Text((b['preview'] ?? '').toString().substring(0, 50)),
                onTap: () => _openBook(b['filename']),
              );
            },
          );
  }

  Widget _buildQA() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TextField(controller: _questionController, decoration: const InputDecoration(labelText: '请输入问题', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 48, child: FilledButton(
        onPressed: _qaLoading ? null : _ask,
        child: _qaLoading ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : const Text('提问'),
      )),
      if (_answer != null) Card(
        margin: const EdgeInsets.only(top: 16),
        child: Padding(padding: const EdgeInsets.all(12), child: MarkdownBody(data: _answer!, selectable: true)),
      ),
    ],
  );
}
