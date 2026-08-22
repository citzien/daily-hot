import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/api_service.dart';
import '../services/feed_service.dart';
import '../services/app_settings.dart';
import '../services/github_i18n.dart';
import '../models/hot_item.dart';
import '../models/github_project.dart';
import '../models/ai_news.dart';
import 'detail_page.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<int> onThemeColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final List<Color> accentColors;

  const HomeScreen({
    super.key,
    required this.initialThemeMode,
    required this.onThemeModeChanged,
    required this.onThemeColorChanged,
    required this.onFontScaleChanged,
    required this.accentColors,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  List<HotItem> _techItems = [];
  List<HotItem> _politicsItems = [];
  List<GithubProject> _githubItems = [];
  List<AiNews> _aiItems = [];

  List<String> _tabs = const ['全部', '科技', '时政', 'AI', '开源'];
  String _density = 'cozy';
  String _timeMode = 'relative';
  String _openLinkMode = 'browser';
  String _codeFont = 'system';

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final s = await AppSettings.load();
    final tabs = await AppSettings.loadTabs();
    if (!mounted) return;
    setState(() {
      _tabs = tabs.isEmpty ? const ['全部', '科技', '时政', 'AI', '开源'] : tabs;
      _density = s['density'] as String;
      _timeMode = s['timeMode'] as String;
      _openLinkMode = s['openLinkMode'] as String;
      _codeFont = s['codeFont'] as String;
    });
    await _fetchData();
  }

  Future<void> _fetchData({bool force = false}) async {
    setState(() => _isLoading = true);
    try {
      // 读取设置：条数 / 摘要 / 数据源开关
      final s = await AppSettings.load();
      final feedLimit = s['feedLimit'] as int;
      final showSummary = s['showSummary'] as bool;
      final disabledSources = <String>{
        if (!(s['srcIthome'] as bool)) 'IT之家',
        if (!(s['srcSspai'] as bool)) '少数派',
        if (!(s['srcPeople'] as bool)) '人民网时政',
      };

      // 科技/时政：内置 RSS 内容提取（IT之家/少数派/人民网）
      final feeds = await FeedService().fetch(disabledSources: disabledSources, force: force);
      final tech = <HotItem>[];
      final politics = <HotItem>[];
      var ti = 0;
      var pi = 0;
      for (final f in feeds) {
        if (f.category == '科技') {
          tech.add(HotItem(
            rank: ++ti,
            title: f.title,
            category: '科技',
            desc: (showSummary && f.summary.isNotEmpty) ? f.summary : null,
            url: f.url,
            pubDate: f.pubDate,
          ));
        } else {
          politics.add(HotItem(
            rank: ++pi,
            title: f.title,
            category: '时政',
            desc: (showSummary && f.summary.isNotEmpty) ? f.summary : null,
            url: f.url,
            pubDate: f.pubDate,
          ));
        }
      }

      // GitHub：真实 API，失败降级 mock；简介并行做在线本地化翻译
      var github = await FeedService().fetchGithub() ?? const <GithubProject>[];
      if (github.isEmpty) {
        final mock = await ApiService.fetchAll();
        github = (mock['github'] as List? ?? [])
            .map((e) => GithubProject.fromJson(e))
            .toList();
      }
      github = await Future.wait(github.map((g) async => GithubProject(
            name: g.name,
            desc: await GithubI18n.localizeDesc(g.name, g.desc),
            lang: g.lang,
            stars: g.stars,
            forks: g.forks,
            url: g.url,
          )));

      // AI：HuggingFace 趋势模型（真实条目，带模型页链接与中文摘要），失败降级本地精选
      var ai = await FeedService().fetchAi() ?? const <AiNews>[];
      if (ai == null || ai.isEmpty) {
        final mockAll = await ApiService.fetchAll();
        ai = (mockAll['ai'] as List? ?? [])
            .map((e) => AiNews.fromJson(e))
            .toList();
      }

      setState(() {
        _techItems = tech.take(feedLimit).toList();
        _politicsItems = politics.take(feedLimit).toList();
        _githubItems = github;
        _aiItems = ai;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
    setState(() => _isLoading = false);
  }

  void _openDetail(DetailPage page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  /// 按用户偏好格式化时间：相对（X 分钟前）或绝对（MM-dd HH:mm）。
  String _fmtTime(String? pubDate) {
    if (pubDate == null || pubDate.isEmpty) return '';
    final dt = _parseRssTime(pubDate);
    if (dt == null) return pubDate;
    if (_timeMode == 'absolute') {
      return dt.month.toString().padLeft(2, '0') + '-' +
          dt.day.toString().padLeft(2, '0') + ' ' +
          dt.hour.toString().padLeft(2, '0') + ':' +
          dt.minute.toString().padLeft(2, '0');
    }
    return timeago.format(dt, locale: 'zh');
  }

  static DateTime? _parseRssTime(String s) {
    final d = DateTime.tryParse(s);
    if (d != null) return d.toLocal();
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final re = RegExp(r'(\d{1,2})\s+(\w{3})\s+(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?');
    final m = re.firstMatch(s);
    if (m == null) return null;
    final mon = months[m.group(2)!];
    if (mon == null) return null;
    return DateTime(
      int.parse(m.group(3)!),
      mon,
      int.parse(m.group(1)!),
      int.parse(m.group(4)!),
      int.parse(m.group(5)!),
      m.group(6) != null ? int.parse(m.group(6)!) : 0,
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SettingsPage(
        currentMode: widget.initialThemeMode,
        onModeChanged: widget.onThemeModeChanged,
        currentColorIndex: 0,
        onColorChanged: widget.onThemeColorChanged,
        currentFontScale: 1.0,
        onFontScaleChanged: widget.onFontScaleChanged,
        accentColors: widget.accentColors,
      ),
    ));
    // 返回后重读分类/偏好并刷新
    await _initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日热点'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_tabs.length, (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_tabs[i]),
                  selected: _selectedIndex == i,
                  onSelected: (_) => setState(() => _selectedIndex = i),
                ),
              )),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _fetchData(force: true),
                    child: _buildContent(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final tab = _tabs[_selectedIndex];
    List<Widget> cards;
    if (tab == '科技') {
      cards = [_buildHotCard('科技热点', Icons.memory_outlined, _techItems)];
    } else if (tab == '时政') {
      cards = [_buildHotCard('时政热点', Icons.account_balance_outlined, _politicsItems)];
    } else if (tab == 'AI') {
      cards = [_buildAiCard()];
    } else if (tab == '开源') {
      cards = [_buildGithubCard()];
    } else {
      cards = [
        _buildHotCard('科技热点', Icons.memory_outlined, _techItems),
        _buildHotCard('时政热点', Icons.account_balance_outlined, _politicsItems),
        _buildAiCard(),
        _buildGithubCard(),
      ];
    }
    final pad = _density == 'compact' ? 12.0 : 16.0;
    return ListView(
      padding: EdgeInsets.all(pad),
      children: [
        for (final c in cards) c,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAiCard() {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, size: 20),
                const SizedBox(width: 8),
                const Text('AI 热点', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _aiItems.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openDetail(DetailPage(
                  title: _aiItems[i].title,
                  category: 'AI',
                  source: _aiItems[i].source,
                  url: _aiItems[i].url.isEmpty ? null : _aiItems[i].url,
                  fields: [DetailField('来源', _aiItems[i].source)],
                  paragraphs: [_aiItems[i].desc],
                )),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_aiItems[i].title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_aiItems[i].desc, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant), maxLines: 2),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGithubCard() {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.code, size: 20),
                SizedBox(width: 8),
                Text('GitHub 开源项目', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _githubItems.length && i < 5; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openDetail(DetailPage(
                  title: _githubItems[i].name,
                  category: '开源',
                  source: 'GitHub Trending',
                  url: _githubItems[i].url.isEmpty ? null : _githubItems[i].url,
                  fields: [
                    DetailField('用途', _githubItems[i].desc),
                    DetailField('语言', _githubItems[i].lang.isEmpty ? '—' : _githubItems[i].lang),
                    DetailField('Star', _githubItems[i].stars),
                    DetailField('Fork', _githubItems[i].forks),
                  ],
                  paragraphs: [
                    '这是开源社区当前热门的项目 ' + _githubItems[i].name + '。主要用途：' + _githubItems[i].desc + '。',
                  ],
                )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(_githubItems[i].name, style: TextStyle(fontSize: 13, fontFamily: _codeFont == 'mono' ? 'monospace' : null, fontWeight: FontWeight.w600))),
                          Text(_githubItems[i].stars, style: TextStyle(fontSize: 12, color: Colors.amber[700])),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _githubItems[i].desc,
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHotCard(String title, IconData icon, List<HotItem> items) {
    if (items.isEmpty) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openDetail(DetailPage(
                  title: items[i].title,
                  category: items[i].category,
                  source: title,
                  pubDate: items[i].pubDate,
                  url: items[i].url.isEmpty ? null : items[i].url,
                  fields: [
                    DetailField('排名', '#' + items[i].rank.toString()),
                    if (items[i].pubDate != null) DetailField('发布时间', items[i].pubDate!),
                  ],
                  paragraphs: [
                    items[i].desc ?? '暂无摘要，点击底部「查看原文」可跳转原内容。',
                  ],
                )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              items[i].rank.toString(),
                              style: TextStyle(
                                color: items[i].rank <= 3 ? Colors.red : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              items[i].title,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      if (items[i].desc != null && items[i].desc!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text(
                            items[i].desc!,
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (items[i].pubDate != null && _fmtTime(items[i].pubDate).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text(
                            _fmtTime(items[i].pubDate),
                            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ],
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
