import 'package:flutter/material.dart';

class HotListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String source;
  final List<HotItem>? items;

  const HotListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.source,
    this.items,
  });

  // 模拟数据
  static final List<HotItem> _mockItems = [
    HotItem(rank: 1, title: '国产大飞机 C919 商业载客突破 100 万人次', heat: '1250万', isHot: true),
    HotItem(rank: 2, title: '工信部发布人工智能发展白皮书', heat: '980万', isHot: true),
    HotItem(rank: 3, title: '华为发布鸿蒙 NEXT 开发者预览版', heat: '856万', isHot: false),
    HotItem(rank: 4, title: '比亚迪第 1000 万辆新能源汽车下线', heat: '720万', isHot: false),
    HotItem(rank: 5, title: '央行宣布降准 0.5 个百分点', heat: '680万', isHot: false),
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
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '7:30 更新',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ..._buildItems(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final itemsToShow = _mockItems.length > 5 ? _mockItems.sublist(0, 5) : _mockItems;
    return itemsToShow.map((item) => _buildListItem(context, item)).toList();
  }

  Widget _buildListItem(BuildContext context, HotItem item) {
    return InkWell(
      onTap: () { },
      onLongPress: () { },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.rank <= 3 ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  item.rank.toString(),
                  style: TextStyle(
                    color: item.rank <= 3 ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.heat != null) ...[
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, size: 14, color: Colors.orange.withValues(alpha: 0.7)),
                  const SizedBox(width: 2),
                  Text(
                    item.heat!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
            if (item.isHot) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '热',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HotItem {
  final int rank;
  final String title;
  final String? heat;
  final bool isHot;

  HotItem({
    required this.rank,
    required this.title,
    this.heat,
    this.isHot = false,
  });
}
