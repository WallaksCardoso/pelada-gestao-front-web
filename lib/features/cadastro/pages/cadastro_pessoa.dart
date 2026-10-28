import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/config.dart';

const String baseUrl = AppConfig.apiPessoas;

class CadastroPessoaPage extends StatefulWidget {
  const CadastroPessoaPage({super.key});

  @override
  State<CadastroPessoaPage> createState() => _CadastroPessoaPageState();
}

class _CadastroPessoaPageState extends State<CadastroPessoaPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool carregando = false;

  Future<void> cadastrarPessoa() async {
    final nome = nomeController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || senha.isEmpty) {
      _showToast("Preencha todos os campos", true);
      return;
    }

    setState(() => carregando = true);
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/cadastrar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nome": nome, "senha": senha}),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(await _extrairMensagemErro(res));
      }

      _showToast("Cadastro realizado com sucesso");

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      _showToast(e.toString(), true);
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<String> _extrairMensagemErro(http.Response res) async {
    try {
      final data = jsonDecode(res.body);
      if (data["mensagem"] != null) return data["mensagem"];
      final primeiroErro = data.values.first;
      if (primeiroErro is String) return primeiroErro;
      return "Erro inesperado ao processar o cadastro.";
    } catch (_) {
      return "Erro inesperado ao processar resposta do servidor.";
    }
  }

  void _showToast(String msg, [bool erro = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final assinatura =
        "${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year} - Wallaks Cardoso";

    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Pessoa")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            carregando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: cadastrarPessoa,
                    child: const Text("Cadastrar"),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Voltar"),
            ),
            const Spacer(),
            Text(
              assinatura,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
