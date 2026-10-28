import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../config/config.dart';

const String baseUrl = AppConfig.apiSorteios;

final Uri apiUrlSorteios = Uri.parse('$baseUrl/sorteios');

class SorteiosEmAndamentoPage extends StatefulWidget {
  const SorteiosEmAndamentoPage({super.key});

  @override
  State<SorteiosEmAndamentoPage> createState() => _SorteiosEmAndamentoPageState();
}

class _SorteiosEmAndamentoPageState extends State<SorteiosEmAndamentoPage> {
  final storage = const FlutterSecureStorage();

  bool carregando = false;
  List<dynamic> sorteios = [];
  String? usuarioLogado;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: "token") ?? "";
    if (token.isNotEmpty) {
      try {
        final payloadBase64 = token.split('.')[1];
        final normalized = base64.normalize(payloadBase64);
        final decoded = jsonDecode(utf8.decode(base64Decode(normalized)));
        usuarioLogado = decoded["sub"];
      } catch (_) {}
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  @override
  void initState() {
    super.initState();
    carregarSorteios();
  }

  Future<void> carregarSorteios() async {
    setState(() => carregando = true);
    try {
      final headers = await _getAuthHeaders();
      final res = await http.get(apiUrlSorteios, headers: headers);

      if (res.statusCode != 200) {
        throw Exception(await _extrairMensagemErro(res));
      }

      final data = jsonDecode(res.body);
      setState(() {
        sorteios = data.where((s) => s['sorteado'] == false).toList();
      });
    } catch (e) {
      _showToast(e.toString(), true);
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> deletarSorteio(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Tem certeza que deseja excluir este sorteio?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir")),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => carregando = true);
    try {
      final headers = await _getAuthHeaders();
      final res = await http.delete(
        Uri.parse("$apiUrlSorteios/$id"),
        headers: headers,
      );

      if (res.statusCode != 200) {
        throw Exception(await _extrairMensagemErro(res));
      }

      _showToast("Sorteio excluído.");
      carregarSorteios();
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

  void _abrirJogadores(Map<String, dynamic> sorteio) {
    Navigator.pushNamed(
      context,
      "/cadastroJogador",
      arguments: {
        "sorteioId": sorteio['id'],
        "nomeSorteio": sorteio['nome'] ?? "Sem nome",
        "sorteioJaFeito": sorteio['sorteado'] ?? false,
      },
    );
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
      appBar: AppBar(title: const Text("Sorteios em Andamento")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : sorteios.isEmpty
              ? const Center(child: Text("Nenhum sorteio em andamento."))
              : ListView.builder(
                  itemCount: sorteios.length,
                  itemBuilder: (ctx, i) {
                    final s = sorteios[i];
                    final data = DateTime.tryParse(s['data'] ?? "");
                    final dataFormatada = data != null
                        ? "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}"
                        : "";

                    final isDono = usuarioLogado != null && s['cadastradoPor'] == usuarioLogado;

                    return ListTile(
                      title: Text("${s['nome'] ?? 'Sem nome'} - $dataFormatada"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: isDono ? () => deletarSorteio(s['id']) : null,
                      ),
                      onTap: () => _abrirJogadores(s),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          assinatura,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
