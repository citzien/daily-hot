import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_settings.dart';
import 'in_app_viewer.dart';

/// 通用详情字段（标签 + 值），用于展示提取出的元数据。
class DetailField {
  final String label;
  final String value;
  const DetailField(this.label, this.value);
}

/// 原生详情页：把条目提取出的结构化内容用 App 自己的界面展示；
/// 底部提供「查看原文」卡片跳转到原内容链接（系统浏览器）。
class DetailPage extends StatelessWidget {
  final String title;
  final String? category;
  final String? source;
  final String? pubDate;
  final String? url;
  final List<DetailField> fields;
  final List<String> paragraphs;

  const DetailPage({
    super.key,
    required this.title,
    this.category,
    this.source,
    this.pubDate,
    this.url,
    this.fields = const [],
    this.paragraphs = const [],
  });

  Future<void> _openUrl(BuildContext context, String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('链接无效，无法打开')),
      );
      return;
    }
    // 按设置选择：应用内简阅（WebView）或系统浏览器
    final s = await AppSettings.load();
    final mode = s['openLinkMode'] as String;
    if (mode == 'inapp') {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InAppViewer(title: title, url: link),
      ));
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开链接失败：' + link)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(category ?? '详情')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (category != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.35),
          ),
          if (source != null || pubDate != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (source != null)
                  Text('来源：' + source!, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                if (pubDate != null && pubDate!.isNotEmpty)
                  Text('发布于：' + pubDate!, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
          if (fields.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const Divider(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 76,
                            child: Text(
                              fields[i].label,
                              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              fields[i].value,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (paragraphs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('内容摘要', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final p in paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  p,
                  style: TextStyle(fontSize: 15, height: 1.7, color: scheme.onSurface),
                ),
              ),
          ],
          // 底部「查看原文」卡片 —— 跳转原内容链接
          if (url != null && url!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              color: scheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _openUrl(context, url!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 20, color: scheme.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '查看原文',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '本页内容由应用从公开内容源提取整理，仅供信息聚合展示。',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
