import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 在线翻译（免费，无 key）：MyMemory API（本机已实测可用）。
/// 带内存缓存 + 本地持久缓存：同一句只在线翻译一次，离线时也能命中缓存。
class OnlineTranslator {
  static const String kCacheKey = 'trans_cache';

  static final Map<String, String> _mem = {};

  /// 翻译英文到中文；失败返回 null（由调用方决定兜底）。
  static Future<String?> translate(String text) async {
    final t = text.trim();
    if (t.isEmpty) return t;
    if (_mem.containsKey(t)) return _mem[t]!;

    // 本地持久缓存
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(kCacheKey);
    Map<String, dynamic> cache = {};
    if (raw != null) {
      try {
        cache = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    final hit = cache[t];
    if (hit is String && hit.isNotEmpty) {
      _mem[t] = hit;
      return hit;
    }

    final zh = await _mymemory(t);
    if (zh == null || zh.isEmpty || zh == t) return null;

    _mem[t] = zh;
    // 简单裁剪防止缓存无限增长
    if (cache.length >= 300) {
      final drop = cache.keys.take(60).toList();
      for (final k in drop) {
        cache.remove(k);
      }
    }
    cache[t] = zh;
    await p.setString(kCacheKey, jsonEncode(cache));
    return zh;
  }

  static Future<String?> _mymemory(String text) async {
    try {
      final uri = Uri.parse(
          'https://api.mymemory.translated.net/get?q=' +
          Uri.encodeComponent(text) +
          '&langpair=en|zh-CN');
      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) return null;
      final d = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      if (d['responseStatus'] != 200) return null;
      final data = d['responseData'] as Map<String, dynamic>?;
      final zh = data?['translatedText'] as String?;
      if (zh == null || zh.isEmpty) return null;
      // 清理常见 HTML 实体
      return zh
          .replaceAll('&#39;', chr39())
          .replaceAll('&amp;', '&')
          .replaceAll('&quot;', '"')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .trim();
    } catch (_) {
      return null;
    }
  }

  static String chr39() => "'";
}