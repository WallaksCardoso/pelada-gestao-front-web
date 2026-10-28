import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../core/api.dart';
import '../../core/widgets.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;

  Future<void> cadastrar() async {
    final nome = nomeController.text.trim();
    final senha = senhaController.text.trim();
    if (nome.isEmpty || senha.isEmpty) {
      return avisar(context, "Informe o nome e a senha.", erro: true);
    }

    setState(() => carregando = true);
    try {
      await Api.post("${AppConfig.apiPessoas}/cadastrar", {
        "nome": nome,
        "senha": senha,
      });
      if (!mounted) return;
      avisar(context, "Conta criada. Agora é só entrar.");
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) avisar(context, e.mensagem, erro: true);
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
      titulo: "Criar conta",
      subtitulo: "Com a conta você cria suas listas e sorteia os times.",
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
        CampoSenha(controller: senhaController, onSubmitted: cadastrar),
        const SizedBox(height: 24),
        BotaoCarregando(
          texto: "Criar conta",
          carregando: carregando,
          onPressed: cadastrar,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Já tenho conta"),
          ),
        ),
      ],
    );
  }
}
