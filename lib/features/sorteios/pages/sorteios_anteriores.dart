import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = bool.fromEnvironment('dart.vm.product')
    ? 'https://pelada-gestao.onrender.com/api'
    : 'http://localhost:8080/api';

final Uri apiUrlSorteios = Uri.parse('$baseUrl/sorteios');

class SorteiosAnterioresPage extends StatefulWidget {
  const SorteiosAnterioresPage({super.key});

  @override
  State<SorteiosAnterioresPage> createState() => _SorteiosAnterioresPageState();
}

class _SorteiosAnterioresPageState extends State<SorteiosAnterioresPage> {
  final storage = const FlutterSecureStorage();

  bool carregando = false;
  List<dynamic> sorteios = [];

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: "token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  @override
  void initState() {
    super.initState();
    carregarSorteiosAnteriores();
  }

  Future<void> carregarSorteiosAnteriores() async {
    setState(() => carregando = true);
    try {
      final headers = await _getAuthHeaders();
      final res = await http.get(apiUrlSorteios, headers: headers);

      if (res.statusCode != 200) {
        throw Exception("Erro ao buscar sorteios");
      }

      final data = jsonDecode(res.body);
      setState(() {
        sorteios = data.where((s) => s['sorteado'] == true).toList();
      });
    } catch (e) {
      _showToast(e.toString(), true);
    } finally {
      setState(() => carregando = false);
    }
  }

  void _abrirDetalhe(Map<String, dynamic> sorteio) {
    Navigator.pushNamed(
      context,
      "/cadastroJogador",
      arguments: {
        "sorteioId": sorteio['id'],
        "nomeSorteio": sorteio['nome'],
        "sorteioJaFeito": true,
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
      appBar: AppBar(title: const Text("Sorteios Anteriores")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : sorteios.isEmpty
              ? const Center(child: Text("Nenhuma lista fechada."))
              : ListView.builder(
                  itemCount: sorteios.length,
                  itemBuilder: (ctx, i) {
                    final s = sorteios[i];
                    final data = DateTime.tryParse(s['data'] ?? "");
                    final dataFormatada = data != null
                        ? "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}"
                        : "";

                    return ListTile(
                      title: Text("${s['nome']} - $dataFormatada"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _abrirDetalhe(s),
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
