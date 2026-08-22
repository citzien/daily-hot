class HotItem {
  final int rank;
  final String title;
  final String? heat;
  final bool isHot;
  final String? category; // 科技/时政/AI/开源
  final String? desc;     // 摘要/用途说明
  final String url;       // 原文链接（详情页跳转）
  final String? pubDate;  // 发布时间

  HotItem({
    required this.rank,
    required this.title,
    this.heat,
    this.isHot = false,
    this.category,
    this.desc,
    this.url = '',
    this.pubDate,
  });

  factory HotItem.fromJson(Map<String, dynamic> json, int index) {
    final rawHot = json['hot'] ?? json['热度值'] ?? 0;
    bool isHot;
    if (rawHot is bool) {
      isHot = rawHot;
    } else if (rawHot is num) {
      isHot = rawHot > 500000;
    } else {
      isHot = false;
    }
    return HotItem(
      rank: index + 1,
      title: json['title'] ?? json['热词'] ?? json['name'] ?? '',
      heat: json['热度']?.toString(),
      isHot: isHot,
      category: json['category'] as String?,
      desc: json['desc'] as String?,
      url: (json['url'] as String?) ?? '',
      pubDate: json['pubDate'] as String?,
    );
  }
}