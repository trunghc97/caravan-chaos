import 'package:caravan_chaos/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Caravan Chaos renders core mobile controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Caravan Chaos'), findsOneWidget);
    expect(find.text('Rút gió'), findsOneWidget);
    expect(find.text('Seed mới'), findsOneWidget);
    expect(find.text('Hợp đồng'), findsOneWidget);
    expect(find.text('VI'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('Draw wind'), findsOneWidget);
    expect(find.text('Contracts'), findsOneWidget);

    await tester.tap(find.text('VI'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Hợp đồng'));
    await tester.tap(find.text('Hợp đồng'));
    await tester.pumpAndSettle();

    expect(find.text('Saffron Guild'), findsWidgets);

    await tester.tap(find.text('Lượt'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Rút gió'));
    await tester.tap(find.text('Rút gió'));
    await tester.pumpAndSettle();

    expect(find.textContaining('dinar'), findsOneWidget);

    await tester.tap(find.text('Sổ cái'));
    await tester.pumpAndSettle();

    expect(find.textContaining('#'), findsWidgets);
    expect(find.textContaining('Ngày 1'), findsWidgets);
  });
}
