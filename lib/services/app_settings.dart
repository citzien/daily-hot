import 'package:shared_preferences/shared_preferences.dart';

/// 应用设置（SharedPreferences 持久化）。所有用户可调项统一定义在这里。
class AppSettings {
  AppSettings._();

  // 内容
  static const String kFeedLimit = 'feed_limit';
  static const String kShowSummary = 'show_summary';
  static const String kSrcIthome = 'src_ithome';
  static const String kSrcSspai = 'src_sspai';
  static const String kSrcPeople = 'src_people';
  // 外观
  static const String kThemeMode = 'theme_mode';
  static const String kThemeColor = 'theme_color'; // 0蓝 1绿 2紫 3橙 4灰
  static const String kFontScale = 'font_scale';   // 1.0 / 1.15 / 1.3
  static const String kDensity = 'density';        // compact | cozy
  // 分类
  static const String kTabsOrder = 'tabs_order';   // StringList
  static const String kTabsHidden = 'tabs_hidden'; // StringList
  // 时间与原文
  static const String kTimeMode = 'time_mode';     // relative | absolute
  static const String kOpenLinkMode = 'open_link_mode'; // browser | inapp
  // 字体
  static const String kCodeFont = 'code_font';     // system | mono

  static const int defaultFeedLimit = 8;
  static const bool defaultShowSummary = true;
  static const List<String> defaultTabs = ['全部', '科技', '时政', 'AI', '开源'];

  /// 载入分类顺序（过滤掉隐藏项）。
  static Future<List<String>> loadTabs() async {
    final p = await SharedPreferences.getInstance();
    final order = p.getStringList(kTabsOrder) ?? defaultTabs;
    final hidden = p.getStringList(kTabsHidden) ?? const [];
    return order.where((t) => !hidden.contains(t)).toList();
  }

  static Future<void> saveTabs(List<String> tabs, Set<String> hidden) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(kTabsOrder, tabs);
    await p.setStringList(kTabsHidden, hidden.toList());
  }

  /// 载入全部设置为 Map（主页用）。
  static Future<Map<String, dynamic>> load() async {
    final p = await SharedPreferences.getInstance();
    return {
      'feedLimit': p.getInt(kFeedLimit) ?? defaultFeedLimit,
      'showSummary': p.getBool(kShowSummary) ?? defaultShowSummary,
      'srcIthome': p.getBool(kSrcIthome) ?? true,
      'srcSspai': p.getBool(kSrcSspai) ?? true,
      'srcPeople': p.getBool(kSrcPeople) ?? true,
      'density': p.getString(kDensity) ?? 'cozy',
      'timeMode': p.getString(kTimeMode) ?? 'relative',
      'openLinkMode': p.getString(kOpenLinkMode) ?? 'browser',
      'codeFont': p.getString(kCodeFont) ?? 'system',
    };
  }

  static Future<void> save(String key, Object value) async {
    final p = await SharedPreferences.getInstance();
    if (value is int) {
      await p.setInt(key, value);
    } else if (value is bool) {
      await p.setBool(key, value);
    } else if (value is String) {
      await p.setString(key, value);
    }
  }
}