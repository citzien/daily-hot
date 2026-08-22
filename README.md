# 今日热点 App

简洁的每日热点聚合应用，支持科技、时政、AI、开源等多个分类，并带「早间语音播报」。

## 项目结构（规范目录：D:\dsh\clock，ASCII 路径）

- backend/    - Python FastAPI 后端（仅服务 App 内的热榜列表页；早间播报已内置，不依赖它）
- lib/        - Flutter 前端（UI + 语音播报 + 定时播报 + 内置 RSS 内容源）
- android/    - 原生 Android 工程（Flutter 生成）
- app/ web/   - 旧 Capacitor 壳与 Flutter Web 产物（已弃用）

## 快速启动（后端）

    cd D:/dsh/clock/backend
    pip install -r requirements.txt
    python -m uvicorn main:app --host 0.0.0.0 --port 8000

## API 接口

- GET /            - 服务状态
- GET /api/all     - 获取所有数据
- GET /api/weibo   - 微博热搜
- GET /api/zhihu   - 知乎热榜
- GET /api/github  - GitHub 热门项目
- GET /api/ai      - AI 热点
- GET /api/brief   - 早间播报内容（科技/时政 RSS 聚合 + 可朗读文本）
- POST /api/refresh - 手动刷新数据

## 早间语音播报（本次新增骨架）

目标：在小米手机上定时播报科技/时政热点；界面极简；起床时由前台服务自动朗读。

### 实现的骨架（lib/ 下）

| 文件 | 作用 |
|---|---|
| services/tts_service.dart | flutter_tts 封装；中文、语速设置，并尝试优先选用「小爱同学」系统引擎 |
| services/brief_source.dart | 播报内容源：**内置**抓取官方 RSS（IT之家/少数派=科技，人民网时政=时政），无需服务器；全部失败降级占位文案 |
| services/broadcast_service.dart | 定时播报前台服务骨架：到点判断 + 每日只播一次 + 保存/读取计划 |
| screens/timed_broadcast_page.dart | 极简设置页：选时间、开/关定时、立即试听、停止 |
| main.dart | 启动时注册前台任务；home_screen 增加「早间播报」入口与「语音播报」按钮 |

### 怎么发声（小爱同学，本地优先）

- 本 App 用 Android 系统标准的 TTS 引擎发声（flutter_tts 底层是 android.speech.tts.TextToSpeech），
  不需要申请小米开放平台权限，也不用内嵌闭源 SDK。
- 小米把「小爱同学」语言包做成系统 TTS 引擎之一。只要在手机上把首选 TTS 引擎设为小爱：
  设置 → 更多设置 → 语言与输入法 → 文字转语音(TTS) → 首选引擎 → 小爱同学。
- 本 App 启动时还会尝试自动从系统引擎列表里挑「小爱」相关引擎，找不到就回退默认引擎。

### 关键前提：已改为原生 Flutter Android 构建（已完成）

- 本仓库早先的 APK 是 Capacitor 壳包 Flutter Web 产物，无法在后台定时播放 TTS。
  现已生成原生 android/ 平台目录，可直接构建原生 APK。
- 已安装 Flutter 3.47.1（D:\flutter），并配置国内镜像
  （FLUTTER_STORAGE_BASE_URL / PUB_HOSTED_URL）。
- 依赖版本：flutter_foreground_task 11.0.1、flutter_tts 4.2.5。
- ✅ 已迁移：项目规范目录为 D:\dsh\clock（ASCII），旧目录 D:\dsh\闹钟 已弃用。
  （AGP 在 Windows 上拒绝非 ASCII 项目路径，迁移后不再受此限制。）

构建命令（在 D:\dsh\clock 内执行）：

    flutter pub get
    flutter build apk --debug

产物：build\app\outputs\flutter-apk\app-debug.apk（或项目根的 DailyHot-debug.apk）

### 小米手机上的开机/保活设置（前台服务不被杀）

到点播报依赖「前台服务 + 通知」。在小米（MIUI/HyperOS）上请做：

1. 系统「设置 → 应用设置 → 应用管理 → 今日热点 → 自启动」：允许自启动。
2. 「省电策略」：设为「无限制」；并允许后台弹出界面 / 通知权限。
3. App 内开启「定时播报」后，顶部会出现常驻通知（前台服务），不要划掉它。

## 功能进度

- [x] 多平台热榜聚合
- [x] AI 热点追踪
- [x] GitHub Trending
- [x] 下拉刷新
- [x] 播报内容接入真实科技/时政数据（App 内置 RSS 聚合，无需服务器）
- [x] 原生 Android 构建（Flutter 3.47.1 + APK 产出）
- [x] 去除服务器依赖：早间播报纯内置（验证：dart run tool/verify_rss.dart）
---

## 开源合规声明

- **许可证**：本项目基于 MIT 许可证开源（见 LICENSE），代码为原创实现。
- **第三方依赖**：Flutter/Dart 生态依赖包均采用 MIT / BSD / Apache-2.0 等宽松许可证；MaterialIcons 图标字体为 Apache-2.0（随 Flutter 分发）。
- **数据与内容版权**：应用内聚合展示的内容来自以下公开渠道，**内容版权归原媒体/平台所有**，本应用仅做标题与摘要的聚合展示，并提供原文链接跳转，不缓存正文、不存储用户数据：
  - 科技：IT之家、少数派 官方 RSS
  - 时政：人民网时政 RSS
  - 开源项目：GitHub 官方搜索 API（简介为本地在线翻译，来源于 MyMemory 免费翻译服务）
  - AI 热点：HuggingFace 趋势模型 API
- **免责声明**：本应用为第三方非官方应用，与 IT之家、少数派、人民网、GitHub、HuggingFace、MyMemory 等平台及其商标持有人无关；商标归各自持有人所有。若内容来源方提出要求，可通过应用中「数据源开关」禁用对应来源。
- **示例数据**：部分离线降级条目为示例数据，仅用于功能演示。
- **合规提醒（致贡献者）**：请勿在本仓库提交任何 API 密钥、凭据或第三方受版权保护的完整内容快照。

## 功能概览（最新）

- 科技 / 时政 / AI / 开源 分类聚合（内置 RSS + 官方 API）
- 原生详情页：结构化字段 + 内容摘要 + 查看原文（系统浏览器或应用内简阅）
- GitHub 简介在线翻译（本地缓存，断网回退）
- 设置：浅色/深色、强调色、字体大小、列表密度、分类管理、时间格式、数据源开关、缓存清理、检查更新
- 无后端依赖、无账号体系、无数据上传
