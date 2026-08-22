import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DailyHotApp());
}

class DailyHotApp extends StatefulWidget {
  const DailyHotApp({super.key});

  @override
  State<DailyHotApp> createState() => _DailyHotAppState();
}

class _DailyHotAppState extends State<DailyHotApp> {
  // 可选强调色（索引与设置页一致）
  static const _accentColors = <Color>[
    Color(0xFF2E6BE6), // 蓝
    Color(0xFF2E9E5B), // 绿
    Color(0xFF7A5CF0), // 紫
    Color(0xFFE67A2E), // 橙
    Color(0xFF5C636B), // 灰
  ];

  ThemeMode _themeMode = ThemeMode.system;
  int _themeColorIndex = 0;
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final mode = p.getString(AppSettings.kThemeMode) ?? 'system';
    final color = p.getInt(AppSettings.kThemeColor) ?? 0;
    final font = p.getDouble(AppSettings.kFontScale) ?? 1.0;
    if (!mounted) return;
    setState(() {
      _themeMode = mode == 'light'
          ? ThemeMode.light
          : mode == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
      _themeColorIndex = color.clamp(0, _accentColors.length - 1);
      _fontScale = font;
    });
  }

  ThemeData _theme(Brightness b) {
    final primary = _accentColors[_themeColorIndex];
    final isLight = b == Brightness.light;
    final base = ColorScheme.fromSeed(seedColor: primary, brightness: b);
    final scheme = base.copyWith(
      surface: isLight ? Colors.white : Colors.black,
      background: isLight ? Colors.white : Colors.black,
      surfaceContainerHighest: isLight ? const Color(0xFFECEEF1) : const Color(0xFF1F2226),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? Colors.white : Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? Colors.white : Colors.black,
        foregroundColor: isLight ? const Color(0xFF1A1C1E) : const Color(0xFFE4E6EA),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? Colors.white : const Color(0xFF141518),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: isLight ? const Color(0xFFE4E7EB) : const Color(0xFF262B2F)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '今日热点',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_fontScale),
        ),
        child: child!,
      ),
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      home: HomeScreen(
        initialThemeMode: _themeMode,
        onThemeModeChanged: (mode) async {
          setState(() => _themeMode = mode);
          final v = mode == ThemeMode.light
              ? 'light'
              : mode == ThemeMode.dark
                  ? 'dark'
                  : 'system';
          await AppSettings.save(AppSettings.kThemeMode, v);
        },
        onThemeColorChanged: (index) async {
          setState(() => _themeColorIndex = index);
          await AppSettings.save(AppSettings.kThemeColor, index);
        },
        onFontScaleChanged: (scale) async {
          setState(() => _fontScale = scale);
          await AppSettings.save(AppSettings.kFontScale, scale);
        },
        accentColors: _accentColors,
      ),
    );
  }
}
