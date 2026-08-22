import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  static bool _offlineMode = true;

  static Future<Map<String, dynamic>> fetchAll() async {
    if (_offlineMode) {
      return _getOfflineData();
    }
    try {
      final resp = await http.get(Uri.parse('$baseUrl/api/all'))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        return json.decode(resp.body);
      }
    } catch (e) {
      debugPrint('Using offline data');
    }
    return _getOfflineData();
  }

  static Map<String, dynamic> _getOfflineData() {
    return {
      'weibo': [
        {'title': '国产大飞机 C919 商业载客突破100万人次', 'url': 'https://s.weibo.com/weibo?q=' + Uri.encodeComponent('C919 商业载客突破100万人次'), 'hot': true, 'category': '科技', 'desc': 'C919 累计承运旅客突破 100 万人次，标志着国产干线客机规模化商业运营迈上新台阶。'},
        {'title': '工信部发布人工智能发展白皮书', 'url': 'https://s.weibo.com/weibo?q=' + Uri.encodeComponent('人工智能发展白皮书'), 'hot': true, 'category': '科技', 'desc': '白皮书系统梳理我国 AI 产业现状与政策方向，提出大模型应用与算力基础设施建设重点。'},
        {'title': '华为发布鸿蒙 NEXT 开发者预览版', 'url': 'https://s.weibo.com/weibo?q=' + Uri.encodeComponent('鸿蒙 NEXT 开发者预览版'), 'hot': false, 'category': '科技', 'desc': '全新纯血鸿蒙不再兼容安卓应用，开发者生态与原生应用适配成为关注焦点。'},
        {'title': '比亚迪第1000万辆新能源汽车下线', 'url': 'https://s.weibo.com/weibo?q=' + Uri.encodeComponent('比亚迪第1000万辆新能源汽车'), 'hot': false, 'category': '科技', 'desc': '比亚迪成为全球首个新能源汽车产量破千万的车企，出海与高端化进程加速。'},
        {'title': '央行宣布降准0.5个百分点', 'url': 'https://s.weibo.com/weibo?q=' + Uri.encodeComponent('央行降准0.5个百分点'), 'hot': false, 'category': '时政', 'desc': '央行全面降准 0.5 个百分点，释放长期流动性，支持实体经济发展。'},
      ],
      'zhihu': [
        {'title': '为什么 GPT-5 这么火', 'url': 'https://www.zhihu.com/search?type=content&q=' + Uri.encodeComponent('GPT-5'), 'hot': true, 'category': '科技', 'desc': '从能力跃升、推理成本下降到应用落地，解析 GPT-5 引发的行业讨论。'},
        {'title': '小米汽车交付超预期', 'url': 'https://www.zhihu.com/search?type=content&q=' + Uri.encodeComponent('小米汽车交付'), 'hot': false, 'category': '科技', 'desc': '小米 SU7 连续多月交付破万，产能爬坡与智驾能力成为核心亮点。'},
        {'title': '程序员如何应对 AI 取代', 'url': 'https://www.zhihu.com/search?type=content&q=' + Uri.encodeComponent('程序员 AI 取代'), 'hot': false, 'category': '科技', 'desc': 'AI 编程助手普及下，程序员的技能结构、工具链与职业路径正在被重塑。'},
      ],
      'github': [
        {'name': 'codecrafters-io/build-your-own-x', 'desc': '从零构建核心技术', 'lang': 'Markdown', 'stars': 541713, 'forks': 51096, 'url': 'https://github.com/codecrafters-io/build-your-own-x'},
        {'name': 'sindresorhus/awesome', 'desc': 'Awesome lists', 'lang': '', 'stars': 498432, 'forks': 36506, 'url': 'https://github.com/sindresorhus/awesome'},
        {'name': 'public-apis/public-apis', 'desc': '免费 API 集合', 'lang': 'Python', 'stars': 467531, 'forks': 51566, 'url': 'https://github.com/public-apis/public-apis'},
        {'name': 'openai/gpt-5', 'desc': 'GPT-5 模型', 'lang': 'Python', 'stars': 386995, 'forks': 81285, 'url': 'https://github.com/openai/gpt-5'},
        {'name': 'anthropic/claude-code', 'desc': 'AI 编程助手', 'lang': 'Python', 'stars': 234567, 'forks': 12345, 'url': 'https://github.com/anthropic/claude-code'},
      ],
      'ai': [
        {'name': 'Claude 4 发布', 'desc': 'Anthropic 新一代大模型：支持 100K 上下文、更强代码与多模态能力，已在 Anthropic 官网开放使用。', 'source': 'Anthropic', 'url': 'https://www.anthropic.com/news'},
        {'name': 'GPT-5 性能曝光', 'desc': 'OpenAI 新一代模型在推理、编码与多模态基准上大幅超越前代，API 与消费端分阶段上线。', 'source': 'OpenAI', 'url': 'https://openai.com/'},
        {'name': '开源 LLama4 发布', 'desc': 'Meta 开源新一代羊驼模型，包含 1B/10B 等尺寸，支持超长上下文，可在本地部署推理。', 'source': 'GitHub', 'url': 'https://github.com/meta-llama'},
        {'name': 'Runway Gen-3 上线', 'desc': 'AI 视频生成升级：支持 10 秒高清视频与更强一致性控制，面向创作者开放。', 'source': 'Runway', 'url': 'https://runwayml.com/'},
      ],
    };
  }
}