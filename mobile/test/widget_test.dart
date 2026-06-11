import 'package:caravan_chaos/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Caravan Chaos renders core mobile controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Caravan Chaos'), findsOneWidget);
    expect(find.text('Rut gio'), findsOneWidget);
    expect(find.text('Seed moi'), findsOneWidget);
    expect(find.text('Hop dong'), findsOneWidget);

    await tester.ensureVisible(find.text('Hop dong'));
    await tester.tap(find.text('Hop dong'));
    await tester.pumpAndSettle();

    expect(find.text('Saffron Guild'), findsWidgets);

    await tester.tap(find.text('Luot'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Rut gio'));
    await tester.tap(find.text('Rut gio'));
    await tester.pumpAndSettle();

    expect(find.textContaining('dinar'), findsOneWidget);

    await tester.tap(find.text('So cai'));
    await tester.pumpAndSettle();

    expect(find.textContaining('#'), findsWidgets);
    expect(find.textContaining('Ngay 1'), findsWidgets);
  });
}
