class AiNews {
  final String title;
  final String desc;
  final String source;
  final String url;

  AiNews({required this.title, required this.desc, this.source = 'AI', this.url = ''});

  factory AiNews.fromJson(Map<String, dynamic> json) {
    return AiNews(
      title: json['name'] ?? json['title'] ?? '',
      desc: json['desc'] ?? '',
      source: json['source'] ?? 'AI',
      url: (json['url'] as String?) ?? '',
    );
  }
}