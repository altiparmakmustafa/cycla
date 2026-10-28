import 'package:cycla/app.dart';
import 'package:cycla/providers/subscription_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Cycla ilk açılışta örnek veri olmadan temiz başlar', (WidgetTester tester) async {
    await initializeDateFormatting('tr_TR', null);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const CyclaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cycla'), findsOneWidget);
    expect(find.text('Henüz Fatura veya Abonelik Eklemediniz'), findsOneWidget);
  });
}
