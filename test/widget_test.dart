import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:face_test/main.dart';

void main() {
  testWidgets('SplashScreen shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // SplashScreen이 로딩 인디케이터를 표시하는지 확인
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.face), findsOneWidget);
  });
}
