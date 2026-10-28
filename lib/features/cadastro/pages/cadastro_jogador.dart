import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../config/config.dart';

const String baseUrl = AppConfig.apiSorteios;

final Uri apiUrlJogadores = Uri.parse('$baseUrl/jogadores');
final Uri apiUrlSorteio = Uri.parse('$baseUrl/sorteios');

class CadastroJogadorPage extends StatefulWidget {
  final int sorteioId;
  final String nomeSorteio;
  final bool sorteioJaFeito;

  const CadastroJogadorPage({
    super.key,
    required this.sorteioId,
    required this.nomeSorteio,
    this.sorteioJaFeito = false,
  });

  @override
  State<CadastroJogadorPage> createState() => _CadastroJogadorPageState();
}

class _CadastroJogadorPageState extends State<CadastroJogadorPage> {
  final TextEditingController nomeController = TextEditingController();
  final storage = const FlutterSecureStorage();

  bool goleiroAtivo = false;
  bool carregando = false;
  List<dynamic> jogadores = [];

  @override
  void initState() {
    super.initState();
    carregarJogadores();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: "token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<void> carregarJogadores() async {
    setState(() => carregando = true);
    try {
      final headers = await _getAuthHeaders();
      final res = await http.get(apiUrlJogadores, headers: headers);

      if (res.statusCode != 200) {
        throw Exception(await _extrairMensagemErro(res));
      }

      final data = jsonDecode(res.body);
      setState(() {
        jogadores = data.where((j) => j['sorteioId'] == widget.sorteioId).toList();
      });
    } catch (e) {
      _showToast(e.toString(), true);
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> adicionarJogador() async {
    final nome = nomeController.text.trim();
    if (nome.isEmpty) return _showToast("Informe o nome do jogador.", true);

    final payload = {
      "nome": nome,
      "goleiro": goleiroAtivo,
      "data": DateTime.now().toIso8601String().split("T")[0],
      "sorteioId": widget.sorteioId
    };

    setState(() => carregando = true);
    try {
      final headers = await _getAuthHeaders();
      final res = await http.post(
        apiUrlJogadores,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(await _extrairMensagemErro(res));
      }

      nomeController.clear();
      setState(() => goleiroAtivo = false);

      _showToast("Jogador adicionado com sucesso.");
      carregarJogadores();
    } catch (e) {
      _showToast(e.toString(), true);
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> deletarJogador(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Tem certeza que deseja excluir este jogador?"),
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
        Uri.parse("$apiUrlJogadores/$id"),
        headers: headers,
      );

      if (res.statusCode != 200) {
        throw Exception(await _extrairMensagemErro(res));
      }

      _showToast("Jogador excluído.");
      carregarJogadores();
    } catch (e) {
      _showToast(e.toString(), true);
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<String> _extrairMensagemErro(http.Response res) async {
    try {
      final data = jsonDecode(res.body);
      return data['mensagem'] ?? "Erro inesperado";
    } catch (_) {
      return "Erro inesperado ao processar resposta";
    }
  }

  void _showToast(String msg, [bool erro = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: erro ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista: ${widget.nomeSorteio}")),
      body: Column(
        children: [
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : jogadores.isEmpty
                    ? const Center(child: Text("Nenhum jogador cadastrado."))
                    : ListView.builder(
                        itemCount: jogadores.length,
                        itemBuilder: (ctx, i) {
                          final jogador = jogadores[i];
                          return ListTile(
                            title: Text(
                              jogador['nome'] + (jogador['goleiro'] ? " - Goleiro" : ""),
                              style: TextStyle(
                                color: jogador['goleiro'] ? Colors.green : null,
                                fontWeight: jogador['goleiro'] ? FontWeight.bold : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: widget.sorteioJaFeito
                                  ? null
                                  : () => deletarJogador(jogador['id']),
                            ),
                          );
                        },
                      ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome do jogador"),
                ),
              ),
              IconButton(
                icon: Icon(
                  goleiroAtivo ? Icons.sports_soccer : Icons.sports,
                  color: goleiroAtivo ? Colors.green : null,
                ),
                onPressed: () => setState(() => goleiroAtivo = !goleiroAtivo),
              ),
              ElevatedButton(
                onPressed: widget.sorteioJaFeito ? null : adicionarJogador,
                child: const Text("Adicionar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
