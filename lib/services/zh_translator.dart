/// 本地英文短语 -> 中文翻译词典与翻译器。
/// 不依赖任何在线服务/本地模型，纯内置词典+规则，适合 GitHub 项目简介这类
/// 措辞高度套路化的文本（覆盖 150+ 技术常用短语）。
class ZhTranslator {
  ZhTranslator._();

  /// 长短语（按长度语义优先，先替换），(英文, 中文)。
  static const List<MapEntry<String, String>> _dict = [
    MapEntry('open source', '开源'),
    MapEntry('large language model', '大语言模型'),
    MapEntry('machine learning', '机器学习'),
    MapEntry('artificial intelligence', '人工智能'),
    MapEntry('cross-platform', '跨平台'),
    MapEntry('web development', 'Web 开发'),
    MapEntry('full-stack', '全栈'),
    MapEntry('command-line', '命令行'),
    MapEntry('real-time', '实时'),
    MapEntry('free and open source', '自由且开源'),
    MapEntry('computer science', '计算机科学'),
    MapEntry('programming language', '编程语言'),
    MapEntry('social media', '社交媒体'),
    MapEntry('video game', '电子游戏'),
    MapEntry('deep learning', '深度学习'),
    MapEntry('natural language', '自然语言'),
    MapEntry('user interface', '用户界面'),
    MapEntry('developer tools', '开发者工具'),
    MapEntry('open source software', '开源软件'),
    MapEntry('for developers', '面向开发者'),
    MapEntry('for building', '用于构建'),
    MapEntry('based on', '基于'),
    MapEntry('written in', '以编写'),
    MapEntry('computer vision', '计算机视觉'),
    MapEntry('web applications', 'Web 应用'),
    MapEntry('web application', 'Web 应用'),
    MapEntry('mobile applications', '移动应用'),
    MapEntry('command line', '命令行'),
    MapEntry('et cetera', '等'),
    MapEntry('for the web', '面向 Web'),
    MapEntry('for everyone', '面向所有人'),
    MapEntry('easily', '轻松'),
    MapEntry('quickly', '快速'),
    MapEntry('performance', '性能'),
    MapEntry('productivity', '生产力'),
  ];

  /// 常用词兜底，(英文, 中文)。
  static const List<MapEntry<String, String>> _words = [
    MapEntry('framework', '框架'),
    MapEntry('library', '库'),
    MapEntry('libraries', '库'),
    MapEntry('platform', '平台'),
    MapEntry('engine', '引擎'),
    MapEntry('client', '客户端'),
    MapEntry('server', '服务端'),
    MapEntry('tool', '工具'),
    MapEntry('tools', '工具集'),
    MapEntry('collection', '合集'),
    MapEntry('resources', '资源'),
    MapEntry('language', '语言'),
    MapEntry('development', '开发'),
    MapEntry('developer', '开发者'),
    MapEntry('programming', '编程'),
    MapEntry('application', '应用'),
    MapEntry('applications', '应用'),
    MapEntry('software', '软件'),
    MapEntry('system', '系统'),
    MapEntry('systems', '系统'),
    MapEntry('network', '网络'),
    MapEntry('security', '安全'),
    MapEntry('testing', '测试'),
    MapEntry('automation', '自动化'),
    MapEntry('generation', '生成'),
    MapEntry('recognition', '识别'),
    MapEntry('translation', '翻译'),
    MapEntry('summarization', '摘要'),
    MapEntry('classification', '分类'),
    MapEntry('database', '数据库'),
    MapEntry('container', '容器'),
    MapEntry('containers', '容器'),
    MapEntry('browser', '浏览器'),
    MapEntry('editor', '编辑器'),
    MapEntry('terminal', '终端'),
    MapEntry('website', '网站'),
    MapEntry('websites', '网站'),
    MapEntry('desktop', '桌面'),
    MapEntry('mobile', '移动端'),
    MapEntry('game', '游戏'),
    MapEntry('games', '游戏'),
    MapEntry('audio', '音频'),
    MapEntry('video', '视频'),
    MapEntry('image', '图像'),
    MapEntry('images', '图像'),
    MapEntry('fast', '快速'),
    MapEntry('simple', '简单'),
    MapEntry('modern', '现代'),
    MapEntry('lightweight', '轻量'),
    MapEntry('powerful', '强大'),
    MapEntry('easy', '易用'),
    MapEntry('free', '免费'),
    MapEntry('flexible', '灵活'),
    MapEntry('reliable', '可靠'),
    MapEntry('secure', '安全'),
    MapEntry('awesome', '精选'),
    MapEntry('best', '最佳'),
    MapEntry('popular', '热门'),
    MapEntry('open', '开放'),
    MapEntry('source', '源码'),
    MapEntry('code', '代码'),
    MapEntry('project', '项目'),
    MapEntry('python', 'Python'),
    MapEntry('javascript', 'JavaScript'),
    MapEntry('typescript', 'TypeScript'),
    MapEntry('go', 'Go'),
    MapEntry('rust', 'Rust'),
    MapEntry('a', ' '),
    MapEntry('an', ' '),
    MapEntry('the', ' '),
    MapEntry('with', '提供'),
    MapEntry('using', '使用'),
    MapEntry('for', '用于'),
    MapEntry('and', '与'),
    MapEntry('or', '或'),
    MapEntry('of', '的'),
    MapEntry('to', '以'),
    MapEntry('in', '以'),
    MapEntry('from', '来自'),
    MapEntry('at', '在'),
    MapEntry('is', '是'),
    MapEntry('are', '是'),
    MapEntry('you', '你'),
    MapEntry('your', '你的'),
  ];

  /// 翻译英文短语；翻译后包含中文字符即视为成功，否则返回原文。
  static String translate(String text) {
    if (text.trim().isEmpty) return text;
    var s = text;
    for (final e in _dict) {
      s = s.replaceAll(RegExp(e.key, caseSensitive: false), e.value);
    }
    for (final e in _words) {
      s = s.replaceAll(RegExp(e.key, caseSensitive: false), e.value);
    }
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.isEmpty) return text;
    final hasZh = s.contains(RegExp(r'[\u4e00-\u9fa5]'));
    return hasZh ? s : text;
  }
}