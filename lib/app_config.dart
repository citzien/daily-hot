/// 构建风味配置：
///   - 个人版：flutter build apk --dart-define=APP_FLAVOR=personal
///     （保留时政 Tab 与人民网源，供自己使用）
///   - 公开版：默认构建（时政默认隐藏，人民网源默认关闭）
class AppConfig {
  AppConfig._();

  static const String _flavor = String.fromEnvironment('APP_FLAVOR', defaultValue: '');

  /// 是否为个人版
  static const bool isPersonal = _flavor == 'personal';
}