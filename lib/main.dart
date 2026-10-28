import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'features/auth/cadastro_page.dart';
import 'features/auth/login_page.dart';
import 'features/listas/lista_page.dart';
import 'features/listas/listas_page.dart';
import 'features/listas/nova_lista_page.dart';

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
      title: "Panelinha",
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      locale: const Locale("pt", "BR"),
      supportedLocales: const [Locale("pt", "BR")],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routes: {
        "/": (_) => const LoginPage(),
        "/cadastro": (_) => const CadastroPage(),
        "/listas": (_) => const ListasPage(),
        "/nova-lista": (_) => const NovaListaPage(),
      },
      onGenerateRoute: (settings) {
        final lista = settings.arguments;
        if (settings.name == "/lista" && lista is Map<String, dynamic>) {
          return MaterialPageRoute(builder: (_) => ListaPage(lista: lista));
        }
        return MaterialPageRoute(builder: (_) => const LoginPage());
      },
    );
  }
}
