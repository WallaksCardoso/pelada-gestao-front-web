import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pelada_gestao_front/core/theme/theme_provider.dart';
import 'package:pelada_gestao_front/main.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('abre na tela de login', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const PeladaGestaoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
  });

  test('o tema escolhido fica salvo para a próxima abertura', () async {
    final provider = ThemeProvider();
    await provider.toggleTheme(true);

    final novaAbertura = ThemeProvider();
    await Future<void>.delayed(Duration.zero);

    expect(novaAbertura.isDarkMode, isTrue);
  });
}
