import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart'; // novo provider
import 'features/auth/login_page.dart';
import 'home/home.dart';
import 'features/cadastro/pages/cadastro_pessoa.dart';
import 'features/cadastro/pages/cadastro_sorteio.dart';
import 'features/sorteios/pages/sorteios_em_andamento.dart';
import 'features/sorteios/pages/sorteios_anteriores.dart';
import 'features/cadastro/pages/cadastro_jogador.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PeladaGestaoApp(),
    ),
  );
}

class PeladaGestaoApp extends StatelessWidget {
  const PeladaGestaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Pelada Gestão',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme, // tema dinâmico
      initialRoute: "/login",
      routes: {
        "/login": (_) => const LoginPage(),
        "/home": (_) => const HomePage(),
        "/cadastroPessoa": (_) => const CadastroPessoaPage(),
        "/cadastroSorteio": (_) => const CadastroSorteioPage(),
        "/sorteiosEmAndamento": (_) => const SorteiosEmAndamentoPage(),
        "/sorteiosAnteriores": (_) => const SorteiosAnterioresPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/cadastroJogador") {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => CadastroJogadorPage(
                sorteioId: args["sorteioId"],
                nomeSorteio: args["nomeSorteio"],
                sorteioJaFeito: args["sorteioJaFeito"] ?? false,
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
