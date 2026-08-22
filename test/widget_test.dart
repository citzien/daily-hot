// 早间播报 App 冒烟测试：验证主界面能正常渲染。

import 'package:flutter_test/flutter_test.dart';
import 'package:daily_hot/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyHotApp());
    await tester.pumpAndSettle();

    // 主界面标题「今日热点」应显示。
    expect(find.text('今日热点'), findsOneWidget);
  });
}