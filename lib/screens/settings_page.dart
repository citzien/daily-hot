import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_settings.dart';
import '../services/feed_service.dart';
import '../services/update_service.dart';

/// 设置页：外观（主题/强调色/字体大小/密度）+ 内容 + 分类管理
/// + 阅读偏好 + 数据（缓存/来源说明）+ 更新检查。
class SettingsPage extends StatefulWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;
  final int currentColorIndex;
  final ValueChanged<int> onColorChanged;
  final double currentFontScale;
  final ValueChanged<double> onFontScaleChanged;
  final List<Color> accentColors;

  const SettingsPage({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.currentColorIndex,
    required this.onColorChanged,
    required this.currentFontScale,
    required this.onFontScaleChanged,
    required this.accentColors,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _feedLimit = AppSettings.defaultFeedLimit;
  bool _showSummary = true;
  bool _srcIthome = true;
  bool _srcSspai = true;
  bool _srcPeople = true;
  String _density = 'cozy';
  String _timeMode = 'relative';
  String _openLinkMode = 'browser';
  String _codeFont = 'system';
  int _cacheBytes = 0;
  bool _checking = false;

  late List<String> _tabs;
  final Set<String> _hiddenTabs = {};

  @override
  void initState() {
    super.initState();
    _tabs = List.of(AppSettings.defaultTabs);
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final s = await AppSettings.load();
    final order = p.getStringList(AppSettings.kTabsOrder);
    final hidden = p.getStringList(AppSettings.kTabsHidden) ?? const <String>[];
    final cacheBytes = await FeedService.cacheSize();
    if (!mounted) return;
    setState(() {
      if (order != null && order.isNotEmpty) _tabs = List.of(order);
      _hiddenTabs.addAll(hidden);
      _feedLimit = s['feedLimit'] as int;
      _showSummary = s['showSummary'] as bool;
      _srcIthome = s['srcIthome'] as bool;
      _srcSspai = s['srcSspai'] as bool;
      _srcPeople = s['srcPeople'] as bool;
      _density = s['density'] as String;
      _timeMode = s['timeMode'] as String;
      _openLinkMode = s['openLinkMode'] as String;
      _codeFont = s['codeFont'] as String;
      _cacheBytes = cacheBytes;
    });
  }

  Future<void> _saveTabs() async {
    await AppSettings.saveTabs(_tabs, _hiddenTabs);
  }

  String get _cacheText =>
      _cacheBytes <= 0 ? '无缓存' : _fmtBytes(_cacheBytes);

  String _fmtBytes(int b) {
    if (b < 1024) return b.toString() + ' B';
    if (b < 1024 * 1024) return (b / 1024).toStringAsFixed(1) + ' KB';
    return (b / 1024 / 1024).toStringAsFixed(1) + ' MB';
  }

  Future<void> _clearCache() async {
    await FeedService.clearCache();
    final c = await FeedService.cacheSize();
    if (!mounted) return;
    setState(() => _cacheBytes = c);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缓存已清理')));
  }

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    final result = await UpdateService.check();
    if (!mounted) return;
    setState(() => _checking = false);
    final available = result['available'] == true;
    final downloadUrl = result['url'] as String? ?? '';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('检查更新'),
        content: Text(result['message'] as String),
        actions: [
          if (available && downloadUrl.isNotEmpty)
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final ok = await launchUrl(
                  Uri.parse(downloadUrl),
                  mode: LaunchMode.externalApplication,
                );
                if (!ok && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('打开下载页失败')),
                  );
                }
              },
              child: const Text('前往下载'),
            ),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('知道了')),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('数据来源与隐私'),
        content: const SingleChildScrollView(
          child: Text(
            '内容来源（均在应用内直接抓取，不经过中转服务器）：\n'
            '· 科技：IT之家、少数派 官方 RSS\n'
            '· 时政：人民网时政 RSS\n'
            '· 开源项目：GitHub 官方搜索 API\n'
            '· AI 热点：应用内置精选条目\n\n'
            '内容版权归各来源方所有，本应用仅做聚合展示。'
            '应用不采集、不上传任何个人信息；'
            '内容缓存与设置仅保存在本机。',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('知道了')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant);

    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(title, style: titleStyle),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== 外观 =====
          section('外观'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: widget.currentMode,
                  title: const Text('跟随系统'),
                  onChanged: (v) => widget.onModeChanged(v!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: widget.currentMode,
                  title: const Text('浅色模式'),
                  onChanged: (v) => widget.onModeChanged(v!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: widget.currentMode,
                  title: const Text('深色模式'),
                  onChanged: (v) => widget.onModeChanged(v!),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Text('强调色'),
                      const Spacer(),
                      for (var i = 0; i < widget.accentColors.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: () => widget.onColorChanged(i),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: widget.accentColors[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.currentColorIndex == i
                                      ? scheme.onSurface
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('字体大小'),
                  trailing: SegmentedButton<double>(
                    segments: const [
                      ButtonSegment(value: 1.0, label: Text('标准')),
                      ButtonSegment(value: 1.15, label: Text('大')),
                      ButtonSegment(value: 1.3, label: Text('特大')),
                    ],
                    selected: {widget.currentFontScale},
                    onSelectionChanged: (s) => widget.onFontScaleChanged(s.first),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda_outlined),
                  title: const Text('列表密度'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'compact', label: Text('紧凑')),
                      ButtonSegment(value: 'cozy', label: Text('舒适')),
                    ],
                    selected: {_density},
                    onSelectionChanged: (s) {
                      setState(() => _density = s.first);
                      AppSettings.save(AppSettings.kDensity, s.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== 内容 =====
          section('内容'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.format_list_numbered),
                  title: const Text('每个分类显示条数'),
                  trailing: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 5, label: Text('5')),
                      ButtonSegment(value: 8, label: Text('8')),
                      ButtonSegment(value: 10, label: Text('10')),
                      ButtonSegment(value: 15, label: Text('15')),
                    ],
                    selected: {_feedLimit},
                    onSelectionChanged: (s) {
                      setState(() => _feedLimit = s.first);
                      AppSettings.save(AppSettings.kFeedLimit, s.first);
                    },
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notes),
                  title: const Text('显示内容摘要'),
                  value: _showSummary,
                  onChanged: (v) {
                    setState(() => _showSummary = v);
                    AppSettings.save(AppSettings.kShowSummary, v);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.public),
                  title: const Text('数据源：IT之家（科技）'),
                  value: _srcIthome,
                  onChanged: (v) {
                    setState(() => _srcIthome = v);
                    AppSettings.save(AppSettings.kSrcIthome, v);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.public),
                  title: const Text('数据源：少数派（科技）'),
                  value: _srcSspai,
                  onChanged: (v) {
                    setState(() => _srcSspai = v);
                    AppSettings.save(AppSettings.kSrcSspai, v);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.public),
                  title: const Text('数据源：人民网时政'),
                  value: _srcPeople,
                  onChanged: (v) {
                    setState(() => _srcPeople = v);
                    AppSettings.save(AppSettings.kSrcPeople, v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== 分类管理 =====
          section('分类管理（顺序与显示）'),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < _tabs.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up),
                      onPressed: i == 0 ? null : () {
                        setState(() {
                          final t = _tabs.removeAt(i);
                          _tabs.insert(i - 1, t);
                        });
                        _saveTabs();
                      },
                    ),
                    title: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          onPressed: i == _tabs.length - 1 ? null : () {
                            setState(() {
                              final t = _tabs.removeAt(i);
                              _tabs.insert(i + 1, t);
                            });
                            _saveTabs();
                          },
                        ),
                        Text(_tabs[i]),
                      ],
                    ),
                    trailing: Switch(
                      value: !_hiddenTabs.contains(_tabs[i]),
                      onChanged: (v) {
                        setState(() {
                          if (v) {
                            _hiddenTabs.remove(_tabs[i]);
                          } else {
                            // 至少保留一个分类
                            final visible = _tabs.where((t) => !_hiddenTabs.contains(t)).length;
                            if (visible > 1) _hiddenTabs.add(_tabs[i]);
                          }
                        });
                        _saveTabs();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== 阅读偏好 =====
          section('阅读偏好'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('时间显示'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'relative', label: Text('相对时间')),
                      ButtonSegment(value: 'absolute', label: Text('具体时间')),
                    ],
                    selected: {_timeMode},
                    onSelectionChanged: (s) {
                      setState(() => _timeMode = s.first);
                      AppSettings.save(AppSettings.kTimeMode, s.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('打开原文方式'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'browser', label: Text('系统浏览器')),
                      ButtonSegment(value: 'inapp', label: Text('应用内查看')),
                    ],
                    selected: {_openLinkMode},
                    onSelectionChanged: (s) {
                      setState(() => _openLinkMode = s.first);
                      AppSettings.save(AppSettings.kOpenLinkMode, s.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('代码字体（项目名等）'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'system', label: Text('默认')),
                      ButtonSegment(value: 'mono', label: Text('等宽')),
                    ],
                    selected: {_codeFont},
                    onSelectionChanged: (s) {
                      setState(() => _codeFont = s.first);
                      AppSettings.save(AppSettings.kCodeFont, s.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== 数据 =====
          section('数据'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('清理缓存'),
                  subtitle: Text('RSS 聚合缓存：' + _cacheText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _cacheBytes > 0 ? _clearCache : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('数据来源与隐私'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPrivacy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== 关于 =====
          section('关于'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('当前版本'),
                  trailing: Text('v' + UpdateService.appVersion + '.1'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.system_update_alt),
                  title: const Text('检查更新'),
                  subtitle: const Text('渠道：GitHub Releases（可配置）'),
                  trailing: _checking
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  onTap: _checking ? null : _checkUpdate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '今日热点 v' + UpdateService.appVersion + '.1',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
