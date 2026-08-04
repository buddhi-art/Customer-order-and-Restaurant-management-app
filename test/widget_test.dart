import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalpa_coffee/ui/core/widgets/double_bezel_container.dart';

void main() {
  testWidgets('DoubleBezelContainer renders child and bezels correctly', (WidgetTester tester) async {
    const childKey = Key('child-text');
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DoubleBezelContainer(
            outerRadius: 32,
            padding: 6,
            child: Text('Test Content', key: childKey),
          ),
        ),
      ),
    );

    // Verify the child is rendered
    expect(find.byKey(childKey), findsOneWidget);
    expect(find.text('Test Content'), findsOneWidget);
    
    // Verify the container structure
    final doubleBezelFinder = find.byType(DoubleBezelContainer);
    expect(doubleBezelFinder, findsOneWidget);
  });
}
