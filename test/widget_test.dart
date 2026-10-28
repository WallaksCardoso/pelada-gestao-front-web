import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pelada_gestao_front/core/theme/theme_provider.dart';
import 'package:pelada_gestao_front/features/listas/resultado.dart';
import 'package:pelada_gestao_front/main.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const PeladaGestaoApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('abre na tela de login', (tester) async {
    await abrirApp(tester);

    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('leva para a criação de conta', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Criar conta'), findsOneWidget);
    expect(find.text('Já tenho conta'), findsOneWidget);
  });

  testWidgets('avisa quando falta nome ou senha no login', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Informe o nome e a senha.'), findsOneWidget);
  });

  test('abre no tema escuro e lembra a escolha', () async {
    final provider = ThemeProvider();
    await Future<void>.delayed(Duration.zero);
    expect(provider.isDarkMode, isTrue);

    await provider.toggleTheme(false);
    final novaAbertura = ThemeProvider();
    await Future<void>.delayed(Duration.zero);

    expect(novaAbertura.isDarkMode, isFalse);
  });

  test('monta o texto do resultado para o WhatsApp com goleiro primeiro', () {
    final texto = textoDoResultado('Pelada de quinta', '30/10/2026', {
      'timeAzul': [
        {'nome': 'Ana', 'goleiro': false},
        {'nome': 'Bruno', 'goleiro': true},
      ],
      'timeVermelho': [
        {'nome': 'Caio', 'goleiro': false},
      ],
      'reservas': [],
    });

    expect(
      texto,
      'Pelada de quinta - 30/10/2026\n'
      '\n'
      'Time Azul\n'
      '- Bruno (goleiro)\n'
      '- Ana\n'
      '\n'
      'Time Vermelho\n'
      '- Caio',
    );
  });

  test('inclui os reservas quando sobram jogadores', () {
    final texto = textoDoResultado('Racha', '01/11/2026', {
      'timeAzul': [],
      'timeVermelho': [],
      'reservas': [
        {'nome': 'Duda', 'goleiro': false},
      ],
    });

    expect(texto, endsWith('Reservas\n- Duda'));
  });
}
