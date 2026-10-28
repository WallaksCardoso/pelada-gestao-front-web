import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'api.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';

void avisar(BuildContext context, String mensagem, {bool erro = false}) {
  final mensageiro = ScaffoldMessenger.of(context);
  mensageiro.hideCurrentSnackBar();
  mensageiro.showSnackBar(
    SnackBar(
      content: Text(mensagem),
      backgroundColor: erro ? Cores.vermelho : null,
      duration: const Duration(seconds: 3),
    ),
  );
}

void tratarErro(BuildContext context, Object erro) {
  if (erro is ApiException && erro.sessaoExpirada) {
    Api.sair();
    Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false);
  }
  avisar(context, erro.toString(), erro: true);
}

String formatarData(String? iso) {
  final data = DateTime.tryParse(iso ?? "");
  return data == null ? "" : DateFormat("dd/MM/yyyy").format(data);
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String acao,
  bool perigosa = false,
}) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          style: perigosa
              ? FilledButton.styleFrom(
                  backgroundColor: Cores.vermelho,
                  foregroundColor: Colors.white,
                )
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(acao),
        ),
      ],
    ),
  );
  return resposta == true;
}

class Marca extends StatelessWidget {
  final double tamanho;

  const Marca({super.key, this.tamanho = 20});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(tamanho * 0.3),
          decoration: BoxDecoration(
            color: esquema.primary,
            borderRadius: BorderRadius.circular(tamanho * 0.5),
          ),
          child: Icon(
            Icons.sports_soccer,
            size: tamanho,
            color: esquema.onPrimary,
          ),
        ),
        SizedBox(width: tamanho * 0.5),
        Text(
          "Panelinha",
          style: TextStyle(
            fontSize: tamanho,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: esquema.onSurface,
          ),
        ),
      ],
    );
  }
}

class BotaoTema extends StatelessWidget {
  const BotaoTema({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Provider.of<ThemeProvider>(context);
    return IconButton(
      tooltip: tema.isDarkMode ? "Tema claro" : "Tema escuro",
      icon: Icon(
        tema.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      ),
      onPressed: () => tema.toggleTheme(!tema.isDarkMode),
    );
  }
}

class Conteudo extends StatelessWidget {
  final Widget child;
  final double largura;

  const Conteudo({super.key, required this.child, this.largura = 720});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largura),
        child: child,
      ),
    );
  }
}

class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: esquema.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(color: esquema.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class Etiqueta extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color? cor;

  const Etiqueta({
    super.key,
    required this.icone,
    required this.texto,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final corFinal = cor ?? esquema.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 16, color: corFinal),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            color: corFinal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class LayoutAcesso extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<Widget> children;

  const LayoutAcesso({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.2),
            radius: 1.4,
            colors: [
              esquema.primary.withValues(alpha: 0.18),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(top: 8, right: 8, child: BotaoTema()),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: Marca(tamanho: 26)),
                        const SizedBox(height: 32),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  titulo,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  subtitulo,
                                  style: TextStyle(
                                    color: esquema.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ...children,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CampoSenha extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  const CampoSenha({super.key, required this.controller, this.onSubmitted});

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: oculta,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: "Senha",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: oculta ? "Mostrar senha" : "Ocultar senha",
          icon: Icon(
            oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => oculta = !oculta),
        ),
      ),
    );
  }
}

class BotaoCarregando extends StatelessWidget {
  final String texto;
  final bool carregando;
  final VoidCallback? onPressed;
  final IconData? icone;

  const BotaoCarregando({
    super.key,
    required this.texto,
    required this.carregando,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final conteudo = carregando
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icone != null) ...[
                Icon(icone, size: 20),
                const SizedBox(width: 8),
              ],
              Text(texto),
            ],
          );
    return FilledButton(
      onPressed: carregando ? null : onPressed,
      child: conteudo,
    );
  }
}
