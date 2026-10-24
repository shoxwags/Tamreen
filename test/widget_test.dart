import 'package:flutter_test/flutter_test.dart';

import 'package:tamreen/main.dart';

void main() {
  testWidgets('Home screen opens in English and switches to Arabic', (tester) async {
    await tester.pumpWidget(const TamreenApp());
    expect(find.text('Find a trainer for your child'), findsOneWidget);

    await tester.tap(find.text('ع').first);
    await tester.pumpAndSettle();
    expect(find.text('ابحث عن مدرّب لطفلك'), findsOneWidget);
  });
}
