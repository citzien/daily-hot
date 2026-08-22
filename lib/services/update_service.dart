import 'dart:convert';
import 'package:http/http.dart' as http;

/// 更新检查渠道（明确）：
/// 通过 GitHub Releases API（https://api.github.com/repos/OWNER/REPO/releases/latest）
/// 与当前版本比较。仓库地址可配置（[githubOwner]/[githubRepo]），
/// 也可换成自有更新服务器（见 [check] 中 TODO）。
class UpdateService {
  // 与 pubspec version 保持一致
  static const String appVersion = '1.0.0';

  // 发布渠道：GitHub Releases（gh 账号 citzien）
  static const String githubOwner = 'citzien';
  static const String githubRepo = 'daily-hot';

  static String get _latestUrl =>
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  /// 返回检查结果：{ available, latestVersion, url, message }
  static Future<Map<String, dynamic>> check() async {
    if (githubOwner.isEmpty || githubRepo.isEmpty) {
      return {
        'available': false,
        'message': '未配置发布渠道，暂无法远程检查；当前为最新构建。',
      };
    }
    try {
      final resp = await http
          .get(Uri.parse(_latestUrl), headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 404) {
        return {'available': false, 'message': '已是最新版本（仓库暂无正式发布）。'};
      }
      if (resp.statusCode != 200) {
        return {'available': false, 'message': '检查失败（HTTP ' + resp.statusCode.toString() + '）。'};
      }
      final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final tag = (data['tag_name'] as String?) ?? '';
      final url = (data['html_url'] as String?) ?? '';
      final version = tag.replaceAll(RegExp(r'^v'), '');
      final hasNew = _compareVersion(version, appVersion) > 0;
      return {
        'available': hasNew,
        'latestVersion': tag.isEmpty ? '未知' : tag,
        'url': url,
        'message': hasNew
            ? '发现新版本 ' + tag + '。'
            : '已是最新版本（' + tag + '）。',
      };
    } catch (_) {
      return {'available': false, 'message': '检查失败：网络异常或渠道不可达。'};
    }
  }

  /// a>b=1, a==b=0, a<b=-1；支持 1.2.3 与 1.2.3+4 形式。
  static int _compareVersion(String a, String b) {
    List<int> pa(List<String> p) => p
        .map((s) => int.tryParse(s.split('+').first) ?? 0)
        .toList();
    final x = pa(a.split('.'));
    final y = pa(b.split('.'));
    final len = x.length > y.length ? x.length : y.length;
    for (var i = 0; i < len; i++) {
      final xi = i < x.length ? x[i] : 0;
      final yi = i < y.length ? y[i] : 0;
      if (xi != yi) return xi > yi ? 1 : -1;
    }
    return 0;
  }
}