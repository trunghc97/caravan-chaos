import 'package:caravan_chaos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Caravan Chaos starts from menu then opens bot game',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(844, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CaravanChaosApp());

    expect(find.text('Chơi với Bot'), findsOneWidget);
    expect(find.text('Chơi với Người'), findsOneWidget);
    expect(find.text('Sắp ra mắt'), findsOneWidget);
    expect(find.text('Hướng dẫn'), findsOneWidget);

    await tester.tap(find.text('Hướng dẫn'));
    await tester.pumpAndSettle();

    expect(find.text('1. Lượt chơi'), findsOneWidget);
    expect(find.text('2. Mỗi lượt chỉ một hành động'), findsOneWidget);

    Navigator.of(tester.element(find.text('1. Lượt chơi'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('Play with Bot'), findsOneWidget);
    expect(find.text('Tutorials'), findsOneWidget);

    await tester.tap(find.text('Play with Bot'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    await tester.tap(find.text('Đã rõ'));
    await tester.pumpAndSettle();

    expect(find.text('VI'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_rounded), findsWidgets);
    expect(find.byIcon(Icons.air_rounded), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('rail-turn')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.casino_rounded), findsWidgets);
    expect(find.text('Seed mới'), findsOneWidget);
    expect(find.text('Thoát game'), findsOneWidget);
    expect(find.text('Lượt'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('rail-contracts')));
    await tester.pumpAndSettle();

    expect(find.text('Hợp đồng'), findsOneWidget);
    expect(find.text('Saffron Guild'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('rail-turn')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('rail-ledger')));
    await tester.pumpAndSettle();

    expect(find.text('Sổ cái'), findsOneWidget);
    expect(find.textContaining('#'), findsWidgets);
    expect(find.textContaining('Ngày 1'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('rail-exit')));
    await tester.pumpAndSettle();

    expect(find.text('Play with Bot'), findsOneWidget);
  });
}
