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
  late bool sorteado = widget.sorteioJaFeito;
  List<dynamic> jogadores = [];
  Map<String, dynamic>? resultado;

  @override
  void initState() {
    super.initState();
    carregarJogadores();
    if (sorteado) carregarResultado();
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
        jogadores = data
            .where((j) => j['sorteioId'] == widget.sorteioId)
            .toList();
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
      "sorteioId": widget.sorteioId,
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

  Future<void> sortearTimes() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sortear times"),
        content: const Text(
          "Depois do sorteio, a lista não aceita mais jogadores. Continuar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sortear"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await _buscarTimes("sortear", "Times sorteados.");
  }

  Future<void> carregarResultado() => _buscarTimes("resultado");

  Future<void> _buscarTimes(String rota, [String? sucesso]) async {
    setState(() => carregando = true);
    try {
      final headers = await _getAuthHeaders();
      final res = await http.get(
        Uri.parse("$apiUrlSorteio/$rota/${widget.sorteioId}"),
        headers: headers,
      );

      if (res.statusCode != 200) {
        throw Exception(await _extrairMensagemErro(res));
      }

      setState(() {
        resultado = jsonDecode(res.body);
        sorteado = true;
      });
      if (sucesso != null) _showToast(sucesso);
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir"),
          ),
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
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _time(String titulo, String chave, Color cor) {
    final lista = (resultado?[chave] as List<dynamic>?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (lista.isEmpty) const Text("Ninguém"),
            for (final jogador in lista)
              Text(
                jogador['nome'] +
                    (jogador['goleiro'] == true ? " - Goleiro" : ""),
              ),
          ],
        ),
      ),
    );
  }

  Widget _resultado() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _time("Time Azul", "timeAzul", Colors.blue),
        _time("Time Vermelho", "timeVermelho", Colors.red),
        _time("Reservas", "reservas", Colors.grey),
      ],
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
                : resultado != null
                ? _resultado()
                : jogadores.isEmpty
                ? const Center(child: Text("Nenhum jogador cadastrado."))
                : ListView.builder(
                    itemCount: jogadores.length,
                    itemBuilder: (ctx, i) {
                      final jogador = jogadores[i];
                      return ListTile(
                        title: Text(
                          jogador['nome'] +
                              (jogador['goleiro'] ? " - Goleiro" : ""),
                          style: TextStyle(
                            color: jogador['goleiro'] ? Colors.green : null,
                            fontWeight: jogador['goleiro']
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: sorteado
                              ? null
                              : () => deletarJogador(jogador['id']),
                        ),
                      );
                    },
                  ),
          ),
          if (!sorteado)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: jogadores.isEmpty || carregando
                    ? null
                    : sortearTimes,
                child: const Text("Sortear times"),
              ),
            ),
          if (!sorteado)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome do jogador",
                    ),
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
                  onPressed: sorteado ? null : adicionarJogador,
                  child: const Text("Adicionar"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
