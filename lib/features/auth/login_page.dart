import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../core/api.dart';
import '../../core/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nomeController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;

  Future<void> entrar() async {
    final nome = nomeController.text.trim();
    final senha = senhaController.text.trim();
    if (nome.isEmpty || senha.isEmpty) {
      return avisar(context, "Informe o nome e a senha.", erro: true);
    }

    setState(() => carregando = true);
    try {
      final data = await Api.post("${AppConfig.apiAuth}/login", {
        "nome": nome,
        "senha": senha,
      });
      await Api.salvarToken(data["token"]);
      if (mounted) Navigator.pushReplacementNamed(context, "/listas");
    } on ApiException catch (e) {
      if (!mounted) return;
      final semAcesso = e.codigo == 401 || e.codigo == 403;
      avisar(
        context,
        semAcesso ? "Nome ou senha inválidos." : e.mensagem,
        erro: true,
      );
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutAcesso(
      titulo: "Entrar",
      subtitulo: "Monte a lista da pelada e sorteie os times em segundos.",
      children: [
        TextField(
          controller: nomeController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: "Nome",
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        CampoSenha(controller: senhaController, onSubmitted: entrar),
        const SizedBox(height: 24),
        BotaoCarregando(
          texto: "Entrar",
          carregando: carregando,
          onPressed: entrar,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Ainda não tem conta?",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/cadastro"),
              child: const Text("Criar conta"),
            ),
          ],
        ),
      ],
    );
  }
}
