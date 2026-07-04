import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:absenku/main.dart';

void main() {
  testWidgets('App shows a loading indicator while restoring session', (WidgetTester tester) async {
    await tester.pumpWidget(const AbsenKuApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
