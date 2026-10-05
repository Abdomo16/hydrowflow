import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrowflow/features/hydration/presentation/widgets/water_glass.dart';

void main() {
  testWidgets('WaterGlass renders for half progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WaterGlass(progress: 0.5))),
    );

    expect(find.byType(WaterGlass), findsOneWidget);
  });
}
