import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../config/config.dart';

const String baseUrl = AppConfig.apiSorteios;

final Uri apiUrlSorteios = Uri.parse('$baseUrl/sorteios');

class CadastroSorteioPage extends StatefulWidget {
  const CadastroSorteioPage({super.key});

  @override
  State<CadastroSorteioPage> createState() => _CadastroSorteioPageState();
}

class _CadastroSorteioPageState extends State<CadastroSorteioPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController qtdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final storage = const FlutterSecureStorage();

  bool carregando = false;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: "token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<void> criarSorteio() async {
    final nome = nomeController.text.trim();
    final qtd = int.tryParse(qtdController.text.trim());
    final email = emailController.text.trim();
    final data = DateTime.now().toIso8601String().split("T")[0];

    if (nome.isEmpty || qtd == null || qtd <= 0 || email.isEmpty) {
      return _showToast("Preencha todos os campos corretamente.", true);
    }

    if (nome.length > 20) {
      return _showToast("O nome da lista deve ter no máximo 20 caracteres.", true);
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return _showToast("Informe um e-mail válido.", true);
    }

    final payload = {
      "nome": nome,
      "jogadoresPorEquipe": qtd,
      "data": data,
      "emailNotificacao": email
    };

    setState(() => carregando = true);
    try {
      final headers = await _getAuthHeaders();
      final res = await http.post(
        apiUrlSorteios,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(await _extrairMensagemErro(res));
      }

      _showToast("Sorteio criado com sucesso.");
      nomeController.clear();
      qtdController.clear();
      emailController.clear();

      if (mounted) {
        Navigator.pushReplacementNamed(context, "/sorteiosEmAndamento");
      }
    } catch (e) {
      _showToast(e.toString(), true);
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<String> _extrairMensagemErro(http.Response res) async {
    try {
      final data = jsonDecode(res.body);
      return data["mensagem"] ?? "Erro inesperado";
    } catch (_) {
      return "Erro inesperado ao processar resposta do servidor";
    }
  }

  void _showToast(String msg, [bool erro = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: erro ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final assinatura =
        "${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year} - Wallaks Cardoso";

    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Sorteio")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome da Lista"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtdController,
              decoration: const InputDecoration(labelText: "Qtd. por equipe"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "E-mail de notificação"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            carregando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: criarSorteio,
                    child: const Text("Criar Sorteio"),
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
