import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../core/api.dart';
import '../../core/widgets.dart';

class NovaListaPage extends StatefulWidget {
  const NovaListaPage({super.key});

  @override
  State<NovaListaPage> createState() => _NovaListaPageState();
}

class _NovaListaPageState extends State<NovaListaPage> {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  int porTime = 5;
  bool carregando = false;

  Future<void> criar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    if (nome.isEmpty) {
      return avisar(context, "Dê um nome para a lista.", erro: true);
    }
    if (!_email.hasMatch(email)) {
      return avisar(
        context,
        "Informe um e-mail válido para as notificações.",
        erro: true,
      );
    }

    setState(() => carregando = true);
    try {
      final lista = await Api.post("${AppConfig.apiSorteios}/sorteios", {
        "nome": nome,
        "jogadoresPorEquipe": porTime,
        "data": DateTime.now().toIso8601String().split("T")[0],
        "emailNotificacao": email,
      });
      if (!mounted) return;
      avisar(context, "Lista criada. Agora cadastre os jogadores.");
      Navigator.pop(context, lista);
    } catch (e) {
      if (mounted) tratarErro(context, e);
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Nova lista")),
      body: Conteudo(
        largura: 520,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nomeController,
                      maxLength: 20,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Nome da lista",
                        hintText: "Pelada de quinta",
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Jogadores por time",
                      style: TextStyle(
                        color: esquema.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton.outlined(
                          tooltip: "Menos",
                          onPressed: porTime > 1
                              ? () => setState(() => porTime--)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Expanded(
                          child: Text(
                            "$porTime",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton.outlined(
                          tooltip: "Mais",
                          onPressed: porTime < 11
                              ? () => setState(() => porTime++)
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Contando o goleiro, que é sorteado à parte.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => criar(),
                      decoration: const InputDecoration(
                        labelText: "E-mail para notificações",
                        helperText:
                            "Recebe um aviso a cada jogador cadastrado.",
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BotaoCarregando(
                      texto: "Criar lista",
                      icone: Icons.check,
                      carregando: carregando,
                      onPressed: criar,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
