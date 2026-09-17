import 'package:flutter_test/flutter_test.dart';
import 'package:retro_snake/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('main() launches the app', (tester) async {
    SharedPreferences.setMockInitialValues({});

    app.main();
    await tester.pumpAndSettle();

    expect(find.text('SNAKE'), findsOneWidget);
  });
}
