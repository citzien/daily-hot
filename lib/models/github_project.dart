class GithubProject {
  final String name;
  final String desc;
  final String lang;
  final String stars;
  final String forks;
  final String url;

  GithubProject({
    required this.name,
    required this.desc,
    required this.lang,
    required this.stars,
    required this.forks,
    this.url = '',
  });

  factory GithubProject.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? json['full_name'] ?? '';
    var s = json['stars'] ?? json['stargazers_count'] ?? 0;
    var f = json['forks'] ?? json['forks_count'] ?? 0;
    return GithubProject(
      name: name,
      desc: json['desc'] ?? json['description'] ?? '',
      lang: json['lang'] ?? json['language'] ?? '',
      stars: s >= 1000 ? (s / 1000).toStringAsFixed(1) + 'k' : s.toString(),
      forks: f >= 1000 ? (f / 1000).toStringAsFixed(1) + 'k' : f.toString(),
      // 注意：GitHub API 的 url 字段是 API 地址（api.github.com/...），
      // 跳转必须用 html_url（仓库页面）或由 full_name 构造。
      url: (json['html_url'] as String?) ??
          ('https://github.com/' + (json['full_name'] ?? name)),
    );
  }
}