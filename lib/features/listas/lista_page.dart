import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/config.dart';
import '../../core/api.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets.dart';
import 'resultado.dart';

class ListaPage extends StatefulWidget {
  final Map<String, dynamic> lista;

  const ListaPage({super.key, required this.lista});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final nomeController = TextEditingController();
  final nomeFoco = FocusNode();

  bool carregando = true;
  bool enviando = false;
  bool goleiro = false;
  late bool sorteada = widget.lista["sorteado"] == true;
  List<dynamic> jogadores = [];
  Map<String, dynamic>? resultado;

  int get id => widget.lista["id"];
  String get nome => widget.lista["nome"] ?? "Sem nome";
  String get data => formatarData(widget.lista["data"]);
  int get porTime => widget.lista["jogadoresPorEquipe"] ?? 0;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() => carregando = true);
    try {
      final todos = await Api.get("${AppConfig.apiSorteios}/jogadores") as List;
      final daLista = todos.where((j) => j["sorteioId"] == id).toList();
      Map<String, dynamic>? times;
      if (sorteada) {
        times = await Api.get(
          "${AppConfig.apiSorteios}/sorteios/resultado/$id",
        );
      }
      setState(() {
        jogadores = daLista;
        resultado = times;
      });
    } catch (e) {
      if (mounted) tratarErro(context, e);
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> adicionar() async {
    final nomeJogador = nomeController.text.trim();
    if (nomeJogador.isEmpty) return;

    setState(() => enviando = true);
    try {
      final jogador = await Api.post("${AppConfig.apiSorteios}/jogadores", {
        "nome": nomeJogador,
        "goleiro": goleiro,
        "data": DateTime.now().toIso8601String().split("T")[0],
        "sorteioId": id,
      });
      nomeController.clear();
      setState(() {
        jogadores = [...jogadores, jogador];
        goleiro = false;
      });
    } catch (e) {
      if (mounted) tratarErro(context, e);
    } finally {
      if (mounted) setState(() => enviando = false);
      nomeFoco.requestFocus();
    }
  }

  Future<void> remover(Map<String, dynamic> jogador) async {
    try {
      await Api.delete("${AppConfig.apiSorteios}/jogadores/${jogador["id"]}");
      setState(
        () => jogadores = jogadores
            .where((j) => j["id"] != jogador["id"])
            .toList(),
      );
    } catch (e) {
      if (mounted) tratarErro(context, e);
    }
  }

  Future<void> sortear() async {
    final ok = await confirmar(
      context,
      titulo: "Sortear times",
      texto: "Depois do sorteio a lista fecha e não aceita mais jogadores.",
      acao: "Sortear",
    );
    if (!ok) return;

    setState(() => enviando = true);
    try {
      final times = await Api.get(
        "${AppConfig.apiSorteios}/sorteios/sortear/$id",
      );
      setState(() {
        resultado = times;
        sorteada = true;
      });
    } catch (e) {
      if (mounted) tratarErro(context, e);
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  Future<void> copiar() async {
    await Clipboard.setData(
      ClipboardData(text: textoDoResultado(nome, data, resultado!)),
    );
    if (mounted) avisar(context, "Resultado copiado. É só colar no grupo.");
  }

  @override
  void dispose() {
    nomeController.dispose();
    nomeFoco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nome)),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : resultado != null
          ? Conteudo(child: _resultado())
          : _montagem(),
    );
  }

  Widget _resumo() {
    final esquema = Theme.of(context).colorScheme;
    final goleiros = jogadores.where((j) => j["goleiro"] == true).length;
    final titulares = porTime * 2;

    Widget numero(String valor, String rotulo, [Color? cor]) => Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
          Text(
            rotulo,
            style: TextStyle(fontSize: 12, color: esquema.onSurfaceVariant),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Etiqueta(icone: Icons.event_outlined, texto: data),
                const Spacer(),
                Etiqueta(
                  icone: sorteada
                      ? Icons.lock_outline
                      : Icons.lock_open_outlined,
                  texto: sorteada ? "Sorteada" : "Aberta",
                  cor: sorteada ? null : esquema.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                numero("${jogadores.length}", "jogadores"),
                numero(
                  "$goleiros",
                  "goleiros",
                  goleiros > 0 ? Cores.goleiro : null,
                ),
                numero(
                  "${jogadores.length.clamp(0, titulares)}/$titulares",
                  "nos times",
                  jogadores.length >= titulares ? esquema.primary : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _montagem() {
    final esquema = Theme.of(context).colorScheme;
    final ordenados = [...jogadores]
      ..sort(
        (a, b) =>
            (b["goleiro"] == true ? 1 : 0) - (a["goleiro"] == true ? 1 : 0),
      );

    return Column(
      children: [
        Expanded(
          child: Conteudo(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _resumo(),
                const SizedBox(height: 16),
                if (ordenados.isEmpty)
                  const EstadoVazio(
                    icone: Icons.group_add_outlined,
                    titulo: "Lista vazia",
                    texto:
                        "Cadastre quem vai jogar no campo abaixo. Marque quem joga no gol.",
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final jogador in ordenados)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  (jogador["goleiro"] == true
                                          ? Cores.goleiro
                                          : esquema.primary)
                                      .withValues(alpha: 0.16),
                              foregroundColor: jogador["goleiro"] == true
                                  ? Cores.goleiro
                                  : esquema.primary,
                              child: jogador["goleiro"] == true
                                  ? const Icon(Icons.sports_handball, size: 20)
                                  : Text(
                                      (jogador["nome"] ?? "?")
                                          .toString()
                                          .characters
                                          .first
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                            title: Text(
                              jogador["nome"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: jogador["goleiro"] == true
                                ? const Text(
                                    "Goleiro",
                                    style: TextStyle(color: Cores.goleiro),
                                  )
                                : null,
                            trailing: IconButton(
                              tooltip: "Remover",
                              icon: Icon(
                                Icons.close,
                                color: esquema.onSurfaceVariant,
                              ),
                              onPressed: () => remover(jogador),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        _compositor(),
      ],
    );
  }

  Widget _compositor() {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: esquema.surface,
        border: Border(top: BorderSide(color: esquema.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Conteudo(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nomeController,
                      focusNode: nomeFoco,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => adicionar(),
                      decoration: const InputDecoration(
                        hintText: "Nome do jogador",
                        prefixIcon: Icon(Icons.person_add_alt_1_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: Icon(
                      Icons.sports_handball,
                      size: 18,
                      color: goleiro ? Cores.goleiro : esquema.onSurfaceVariant,
                    ),
                    showCheckmark: false,
                    label: const Text("Goleiro"),
                    selected: goleiro,
                    onSelected: (v) => setState(() => goleiro = v),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: "Adicionar",
                    onPressed: enviando ? null : adicionar,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BotaoCarregando(
                texto: "Sortear times",
                icone: Icons.shuffle,
                carregando: enviando,
                onPressed: jogadores.length < 2 ? null : sortear,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultado() {
    final times = [
      for (final t in timesDoResultado)
        CardTime(titulo: t.titulo, cor: t.cor, jogadores: resultado![t.chave]),
    ];
    final reservas = resultado!["reservas"] as List?;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _resumo(),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (_, limites) => limites.maxWidth >= 560
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: times[0]),
                    const SizedBox(width: 12),
                    Expanded(child: times[1]),
                  ],
                )
              : Column(
                  children: [times[0], const SizedBox(height: 12), times[1]],
                ),
        ),
        if (reservas != null && reservas.isNotEmpty) ...[
          const SizedBox(height: 12),
          CardTime(
            titulo: "Reservas",
            cor: Theme.of(context).colorScheme.onSurfaceVariant,
            jogadores: reservas,
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: copiar,
          icon: const Icon(Icons.copy_outlined),
          label: const Text("Copiar resultado"),
        ),
      ],
    );
  }
}
