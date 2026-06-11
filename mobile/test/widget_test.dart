import 'package:caravan_chaos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Caravan Chaos renders core mobile controls',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    expect(find.text('VI'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_rounded), findsWidgets);
    expect(find.byIcon(Icons.air_rounded), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('rail-turn')));
    await tester.pumpAndSettle();

    expect(find.text('Rút gió'), findsOneWidget);
    expect(find.text('Seed mới'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('rail-contracts')));
    await tester.pumpAndSettle();

    expect(find.text('Hợp đồng'), findsOneWidget);
    expect(find.text('Saffron Guild'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('rail-turn')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rút gió'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('rail-ledger')));
    await tester.pumpAndSettle();

    expect(find.text('Sổ cái'), findsOneWidget);
    expect(find.textContaining('#'), findsWidgets);
    expect(find.textContaining('Ngày 1'), findsWidgets);
  });
}
