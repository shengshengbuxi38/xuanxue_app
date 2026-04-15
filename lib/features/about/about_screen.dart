import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('缘起')),
      body: const Markdown(
        data: '''每个人都想知道自己的命运。

易经中预测分为**天、地、人**三才。八字是出生时的先天剧本，是**天**的部分，不可改变。但**地**（环境）、**人**（自己的努力）也在影响人的命运。

> 佛经云：万法唯心造。心能转境，则同如来。

---

## 袁了凡先生改命四法

### 一、立命之学
**"命由我作，福自己求。"**

### 二、改过之法
**"有过知非，改之为贵。"**

### 三、积善之方
**"善不积，不足以成名。"**

### 四、谦德之效
**"满招损，谦受益。"**

---

**本App的一切收益全部捐赠给中欧校友国学会，用于传播华夏优秀传统文化。**''',
        selectable: true,
      ),
    );
  }
}
