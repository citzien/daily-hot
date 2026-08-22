import 'package:flutter/material.dart';

class AiNewsCard extends StatelessWidget {
  const AiNewsCard({super.key});

  static final List<AiNews> _mockNews = [
    AiNews(
      title: 'Claude 4 发布',
      desc: 'Anthropic 推出新一代大模型，支持 100K 上下文',
      source: 'HuggingFace',
      time: '2小时前',
      type: AiNewsType.newModel,
    ),
    AiNews(
      title: 'GPT-5 性能曝光',
      desc: '多项基准测试超越 GPT-4，预计 Q2 发布',
      source: 'Product Hunt',
      time: '4小时前',
      type: AiNewsType.leak,
    ),
    AiNews(
      title: '开源 LLama4 发布',
      desc: 'Meta 开源新一代羊驼模型，性能对标 GPT-4',
      source: 'GitHub',
      time: '6小时前',
      type: AiNewsType.openSource,
    ),
    AiNews(
      title: 'Runway Gen-3 上线',
      desc: 'AI 视频生成能力大幅提升，支持 10 秒高清视频',
      source: 'Product Hunt',
      time: '8小时前',
      type: AiNewsType.product,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '🤖 AI 热点',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 新闻列表
            ..._mockNews.map((news) => _buildNewsItem(context, news)),
            
            // 数据来源
            const SizedBox(height: 12),
            Center(
              child: Text(
                '数据来源: HuggingFace · Product Hunt · GitHub Trending',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, AiNews news) {
    return InkWell(
      onTap: () {
        // TODO: 查看详情
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeChip(context, news.type),
                const Spacer(),
                Text(
                  news.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              news.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              news.desc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.source_outlined,
                  size: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  news.source,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.volume_up_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, AiNewsType type) {
    final labels = {
      AiNewsType.newModel: '🆕 新模型',
      AiNewsType.product: '📦 产品',
      AiNewsType.openSource: '🌟 开源',
      AiNewsType.leak: '📰 爆料',
    };
    final colors = {
      AiNewsType.newModel: Colors.blue,
      AiNewsType.product: Colors.green,
      AiNewsType.openSource: Colors.purple,
      AiNewsType.leak: Colors.orange,
    };
    final label = labels[type]!;
    final color = colors[type]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum AiNewsType { newModel, product, openSource, leak }

class AiNews {
  final String title;
  final String desc;
  final String source;
  final String time;
  final AiNewsType type;

  AiNews({
    required this.title,
    required this.desc,
    required this.source,
    required this.time,
    required this.type,
  });
}
