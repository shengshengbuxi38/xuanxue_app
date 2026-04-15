import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownCard extends StatelessWidget {
  final String content;
  const MarkdownCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: MarkdownBody(data: content, selectable: true),
      ),
    );
  }
}
