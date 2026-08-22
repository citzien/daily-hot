import 'package:flutter/material.dart';

class GithubTrendingCard extends StatelessWidget {
  const GithubTrendingCard({super.key});

  static final List<GithubProject> _mockProjects = [
    GithubProject(
      name: 'microsoft/TypeScript',
      desc: 'TypeScript 是一种为 JavaScript 提供类型检查的编程语言。',
      lang: 'TypeScript',
      langColor: 0xFF3178C6,
      stars: '2.3k',
      todayStars: '152',
      forks: '320',
    ),
    GithubProject(
      name: 'openai/gpt-5',
      desc: 'GPT-5: The next generation of AI language model',
      lang: 'Python',
      langColor: 0xFF3572A5,
      stars: '1.8k',
      todayStars: '892',
      forks: '234',
    ),
    GithubProject(
      name: 'anthropic/claude-code',
      desc: '让 Claude 能够操作您的计算机完成复杂任务',
      lang: 'Python',
      langColor: 0xFF3572A5,
      stars: '1.2k',
      todayStars: '456',
      forks: '89',
    ),
    GithubProject(
      name: 'ffmpeg/ffmpeg',
      desc: '音视频处理工具集合',
      lang: 'C',
      langColor: 0xFF555555,
      stars: '980',
      todayStars: '45',
      forks: '1.2k',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
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
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.code,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '💻 GitHub Trending',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '今日',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // 项目列表
            ..._mockProjects.map((project) => _buildProjectItem(context, project)),
            
            // 查看更多
            TextButton.icon(
              onPressed: () {
                // TODO: 打开 GitHub Trending
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('查看更多热门项目'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, GithubProject project) {
    return InkWell(
      onTap: () {
        // TODO: 打开项目详情
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 项目名
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                // 语言
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(project.langColor).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(project.langColor),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.lang,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(project.langColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // 描述
            Text(
              project.desc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // 统计
            Row(
              children: [
                Icon(Icons.star_border, size: 14, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(project.stars, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 16),
                Icon(Icons.call_split, size: 14, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(project.forks, style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward, size: 10, color: Colors.green[700]),
                      const SizedBox(width: 2),
                      Text(
                        project.todayStars,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GithubProject {
  final String name;
  final String desc;
  final String lang;
  final int langColor;
  final String stars;
  final String todayStars;
  final String forks;

  GithubProject({
    required this.name,
    required this.desc,
    required this.lang,
    required this.langColor,
    required this.stars,
    required this.todayStars,
    required this.forks,
  });
}
