/// GitHub 开源项目简介的中文本地化。
/// 内置常见热门项目的中文用途说明；未收录时回退英文原文。
import 'zh_translator.dart';
import 'online_translator.dart';

class GithubI18n {
  static const Map<String, String> _zh = {
    'codecrafters-io/build-your-own-x': '从零亲手实现核心技术（Git、数据库、编译器、操作系统等）的教程合集',
    'sindresorhus/awesome': '精选高质量资源的 Awesome 清单聚合',
    'public-apis/public-apis': '免费开放 API 大全，按分类收录',
    'openai/gpt-5': 'OpenAI 新一代大语言模型的官方/生态项目',
    'anthropic/claude-code': 'Claude 的终端 AI 编程助手',
    'microsoft/TypeScript': 'JavaScript 的类型化超集，提供编译期类型检查',
    'microsoft/vscode': '微软开源的跨平台代码编辑器',
    'facebook/react': '用于构建用户界面的 JavaScript 库',
    'vuejs/vue': '渐进式 JavaScript 前端框架',
    'flutter/flutter': 'Google 的跨平台 UI 框架（本 App 即基于它）',
    'tensorflow/tensorflow': '端到端开源机器学习平台',
    'pytorch/pytorch': '基于 Python 的开源深度学习框架',
    'kubernetes/kubernetes': '容器编排与集群管理平台',
    'rust-lang/rust': '注重性能与内存安全的多范式编程语言',
    'golang/go': 'Google 出品的静态强类型编程语言',
    'yt-dlp/yt-dlp': '命令行视频下载工具（支持大量站点）',
    'jellyfin/jellyfin': '免费开源的媒体服务器',
    'home-assistant/core': '本地优先的智能家居自动化平台',
    'ollama/ollama': '本地运行大模型的工具（开箱即用，支持 GPU）',
    'open-webui/open-webui': '带 Web 界面的本地大模型聊天前端',
    'freeCodeCamp/freeCodeCamp': '免费学习编程的开放式课程平台与社区',
    'EbookFoundation/free-programming-books': '免费编程电子书清单（多语种）',
    'kamranahmedse/developer-roadmap': '开发者成长路线图（前端/后端/运维等）',
    'jwasham/coding-interview-university': '程序员面试准备自学路线（从零到入职）',
    '996icu/996.ICU': '996 工作制相关项目与讨论',
    'vinta/awesome-python': '精选 Python 框架与库合集',
    'practical-tutorials/project-based-learning': '以项目实战驱动的编程学习资源合集',
    'getify/You-Dont-Know-JS': '深入讲解 JavaScript 核心机制的系列书籍',
    'torvalds/linux': 'Linux 内核源码仓库',
    'electron/electron': '用 Web 技术构建跨平台桌面应用的框架',
    'denoland/deno': '由 Node.js 作者开发的现代 JavaScript/TypeScript 运行时',
    'nodejs/node': 'Node.js JavaScript 运行时',
    'microsoft/playwright': '跨浏览器自动化测试与爬取工具',
    'puppeteer/puppeteer': 'Chrome DevTools 驱动的浏览器自动化库',
    'golang-standards/project-layout': 'Go 项目标准目录结构参考',
    'geekan/MetaGPT': '多智能体软件开发框架（需求到代码）',
    'Significant-Gravitas/AutoGPT': '自主执行任务的 AI 智能体实验项目',
    'langchain-ai/langchain': '大模型应用开发框架（链式编排）',
    'huggingface/transformers': '主流 Transformer 模型的开源实现与应用库',
    'ggerganov/llama.cpp': 'C/C++ 实现的大模型本地推理引擎',
    'ComposioHQ/composio': 'AI 智能体接入 250+ 工具的集成层',
    'microsoft/generative-ai-for-beginners': '生成式 AI 入门课程（微软）',
    'SimplifyJobs/New-Grad-Positions': '应届生职位招聘信息聚合',
    'Z4nzu/hackingtool': '渗透测试工具集（仅供学习）',
    'trimstray/the-book-of-secret-knowledge': '运维/安全/网络工程师的工具手册合集',
    'ossu/computer-science': '开源计算机科学专业课程路线（近乎 CS 学位）',
    'tldr-pages/tldr': '精简版命令行手册（man 的速查替代）',
  };

  /// 返回项目的中文用途说明：仓库映射 -> 本地词典翻译 -> 兜底原文（同步，离线兜底用）。
  static String zhDesc(String repoName, String enDesc) {
    final zh = _zh[repoName];
    if (zh != null) return zh;
    if (enDesc.isEmpty) return '暂无描述';
    final translated = ZhTranslator.translate(enDesc);
    return translated.isEmpty ? '暂无描述' : translated;
  }

  /// 中文简介（在线优先）：仓库映射 -> 在线翻译(MyMemory) -> 本地词典兜底。
  static Future<String> localizeDesc(String repoName, String enDesc) async {
    final zh = _zh[repoName];
    if (zh != null) return zh;
    if (enDesc.isEmpty) return '暂无描述';
    final online = await OnlineTranslator.translate(enDesc);
    if (online != null && online != enDesc) return online;
    final local = ZhTranslator.translate(enDesc);
    return local.isEmpty ? '暂无描述' : local;
  }
}