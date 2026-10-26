import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_studying_layse/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('exibe a tela inicial de contatos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Contatos'), findsOneWidget);
    expect(find.text('Nenhum contato cadastrado'), findsOneWidget);
  });
}
