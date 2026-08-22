import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import '../models/github_project.dart';
import '../models/ai_news.dart';

/// 内容提取方式（明确）：
/// App 内置直接抓取官方 RSS，用 XML 解析提取每条内容的
///   标题(title) / 摘要(description) / 原文链接(link) / 发布时间(pubDate)。
/// 不依赖服务器、不使用 WebView；摘要是源站提供的内容摘要，稳定可靠。
/// 聚合结果带 15 分钟本地缓存，可被「清理缓存」清除。
class FeedItem {
  final String title;
  final String summary;
  final String url;
  final String source;
  final String category; // 科技 | 时政
  final String? pubDate;

  const FeedItem({
    required this.title,
    required this.summary,
    required this.url,
    required this.source,
    required this.category,
    this.pubDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'summary': summary,
        'url': url,
        'source': source,
        'category': category,
        'pubDate': pubDate,
      };

  factory FeedItem.fromJson(Map<String, dynamic> j) => FeedItem(
        title: j['title'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        url: j['url'] as String? ?? '',
        source: j['source'] as String? ?? '',
        category: j['category'] as String? ?? '',
        pubDate: j['pubDate'] as String?,
      );
}

class FeedService {
  static const String kCacheKey = 'feed_cache';
  static const Duration cacheTtl = Duration(minutes: 15);

  static const List<_FeedSource> _sources = [
    _FeedSource('IT之家', 'https://www.ithome.com/rss/', '科技'),
    _FeedSource('少数派', 'https://sspai.com/feed', '科技'),
    _FeedSource('掘金', 'https://juejin.cn/rss', '开发者'),
    _FeedSource('极客公园', 'https://www.geekpark.net/rss', '数码'),
    _FeedSource('人民网时政', 'https://www.people.com.cn/rss/politics.xml', '时政'),
  ];

  /// 抓取启用的源并合并；命中 15 分钟内缓存则直接返回。
  /// [force] 为 true 时跳过缓存（下拉刷新用）。
  Future<List<FeedItem>> fetch({
    Set<String> disabledSources = const {},
    bool force = false,
  }) async {
    if (!force) {
      final cached = await _readCache(disabledSources);
      if (cached != null) return cached;
    }
    final enabled = _sources.where((s) => !disabledSources.contains(s.name));
    final results = await Future.wait(enabled.map(_fetchOne));
    final items = <FeedItem>[];
    for (final r in results) {
      if (r != null) items.addAll(r);
    }
    await _writeCache(items, disabledSources);
    return items;
  }

  Future<List<FeedItem>?> _fetchOne(_FeedSource src) async {
    try {
      final resp = await http
          .get(Uri.parse(src.url))
          .timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) return null;
      final body = utf8.decode(resp.bodyBytes).trim();
      if (!body.startsWith('<?xml') && !body.startsWith('<rss')) return null;

      final doc = XmlDocument.parse(body);
      final out = <FeedItem>[];
      for (final item in doc.findAllElements('item')) {
        final title = (item.getElement('title')?.innerText ?? '').trim();
        if (title.isEmpty) continue;
        final url = (item.getElement('link')?.innerText ?? '').trim();
        final summary = _cleanHtml(item.getElement('description')?.innerText ?? '');
        final pubDate = (item.getElement('pubDate')?.innerText ?? '').trim();
        out.add(FeedItem(
          title: title,
          summary: summary,
          url: url,
          source: src.name,
          category: src.category,
          pubDate: pubDate.isEmpty ? null : pubDate,
        ));
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  // ---------- 缓存 ----------

  static Future<List<FeedItem>?> _readCache(Set<String> disabled) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(kCacheKey);
      if (raw == null) return null;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final ts = data['ts'] as int? ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - ts > cacheTtl.inMilliseconds) {
        return null;
      }
      final items = (data['items'] as List? ?? [])
          .map((e) => FeedItem.fromJson(e))
          .toList();
      return items.where((i) => !disabled.contains(i.source)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeCache(List<FeedItem> items, Set<String> disabled) async {
    try {
      final p = await SharedPreferences.getInstance();
      final data = {
        'ts': DateTime.now().millisecondsSinceEpoch,
        'items': items.map((e) => e.toJson()).toList(),
      };
      await p.setString(kCacheKey, jsonEncode(data));
    } catch (_) {
      // 缓存写失败不影响主流程
    }
  }

  /// 当前缓存大小（UTF-8 字节），供设置页「清理缓存」展示。
  static Future<int> cacheSize() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(kCacheKey);
      return raw == null ? 0 : utf8.encode(raw).length;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> clearCache() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(kCacheKey);
  }

  /// 抓取 GitHub 热门开源项目（官方搜索 API，无需令牌，限流宽松）。
  Future<List<GithubProject>?> fetchGithub() async {
    try {
      final resp = await http.get(Uri.parse(
              'https://api.github.com/search/repositories?q=stars:%3E1000&sort=stars&order=desc&per_page=5'))
          .timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final items = data['items'] as List? ?? [];
      return items.map((e) => GithubProject.fromJson(e)).toList();
    } catch (_) {
      return null;
    }
  }

  /// 抓取 AI 热点（HuggingFace 趋势模型）：真实条目，带模型页链接与中文摘要。
  Future<List<AiNews>?> fetchAi() async {
    try {
      final resp = await http.get(Uri.parse(
              'https://huggingface.co/api/models?sort=trending&limit=6'))
          .timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) return null;
      final items = jsonDecode(utf8.decode(resp.bodyBytes)) as List? ?? [];
      final out = <AiNews>[];
      for (final it in items) {
        final id = (it as Map<String, dynamic>)['id'] as String? ?? '';
        final tag = (it['pipeline_tag'] as String?) ?? '';
        final likes = it['likes'] ?? 0;
        final downloads = it['downloads'] ?? 0;
        if (id.isEmpty) continue;
        out.add(AiNews(
          title: id,
          desc: 'HuggingFace 趋势模型：' +
              (_pipelineZh(tag) +
                  '；下载 ' +
                  _numZh(downloads) +
                  ' 次，获 ' +
                  _numZh(likes) +
                  ' 赞。'),
          source: 'HuggingFace',
          url: 'https://huggingface.co/' + id,
        ));
      }
      return out.isEmpty ? null : out;
    } catch (_) {
      return null;
    }
  }

  static String _numZh(Object v) {
    final n = v is num ? v.toDouble() : 0.0;
    if (n >= 100000000) return (n / 100000000).toStringAsFixed(1) + ' 亿';
    if (n >= 10000) return (n / 10000).toStringAsFixed(1) + ' 万';
    return n.toStringAsFixed(0);
  }

  static String _pipelineZh(String tag) {
    const map = {
      'text-generation': '文本生成',
      'text2text-generation': '文本转换/生成',
      'text-embedding': '文本向量化',
      'sentence-similarity': '句向量相似度',
      'feature-extraction': '特征提取',
      'image-classification': '图像分类',
      'image-text-to-text': '多模态图文',
      'text-to-image': '文生图',
      'automatic-speech-recognition': '语音识别',
      'question-answering': '问答',
      'token-classification': '命名实体/序列标注',
      'zero-shot-classification': '零样本分类',
      'object-detection': '目标检测',
      'translation': '翻译',
      'summarization': '摘要生成',
    };
    return map[tag] ?? tag;
  }

  /// 去除 RSS 摘要里的 HTML 标签与常见实体，得到纯文本摘要。
  static String _cleanHtml(String raw) {
    var s = raw.replaceAll(RegExp(r'<[^>]+>'), ' ');
    s = s.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<').replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"').replaceAll('&#39;', "'");
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}

class _FeedSource {
  final String name;
  final String url;
  final String category;
  const _FeedSource(this.name, this.url, this.category);
}
