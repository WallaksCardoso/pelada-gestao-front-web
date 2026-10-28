import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../core/api.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets.dart';

class ListasPage extends StatefulWidget {
  const ListasPage({super.key});

  @override
  State<ListasPage> createState() => _ListasPageState();
}

class _ListasPageState extends State<ListasPage> {
  bool carregando = true;
  bool verSorteadas = false;
  String? usuario;
  List<dynamic> listas = [];
  Map<int, List<dynamic>> jogadoresPorLista = {};

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() => carregando = true);
    try {
      final respostas = await Future.wait([
        Api.get("${AppConfig.apiSorteios}/sorteios"),
        Api.get("${AppConfig.apiSorteios}/jogadores"),
      ]);
      final porLista = <int, List<dynamic>>{};
      for (final jogador in respostas[1] as List) {
        porLista.putIfAbsent(jogador["sorteioId"], () => []).add(jogador);
      }
      usuario = await Api.usuarioLogado();
      final todas = (respostas[0] as List).toList()
        ..sort((a, b) => (b["data"] ?? "").compareTo(a["data"] ?? ""));
      setState(() {
        listas = todas;
        jogadoresPorLista = porLista;
      });
    } catch (e) {
      if (mounted) tratarErro(context, e);
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> excluir(Map<String, dynamic> lista) async {
    final ok = await confirmar(
      context,
      titulo: "Excluir lista",
      texto: "A lista \"${lista["nome"]}\" e os jogadores dela serão apagados.",
      acao: "Excluir",
      perigosa: true,
    );
    if (!ok) return;
    try {
      await Api.delete("${AppConfig.apiSorteios}/sorteios/${lista["id"]}");
      if (!mounted) return;
      avisar(context, "Lista excluída.");
      carregar();
    } catch (e) {
      if (mounted) tratarErro(context, e);
    }
  }

  Future<void> sair() async {
    await Api.sair();
    if (mounted) Navigator.pushReplacementNamed(context, "/");
  }

  Future<void> abrir(Map<String, dynamic> lista) async {
    await Navigator.pushNamed(context, "/lista", arguments: lista);
    carregar();
  }

  Future<void> novaLista() async {
    final lista = await Navigator.pushNamed(context, "/nova-lista");
    if (lista is Map<String, dynamic>) {
      await abrir(lista);
    } else {
      carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final abertas = listas.where((l) => l["sorteado"] != true).toList();
    final sorteadas = listas.where((l) => l["sorteado"] == true).toList();
    final visiveis = verSorteadas ? sorteadas : abertas;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Marca(),
        actions: [
          const BotaoTema(),
          IconButton(
            tooltip: "Sair",
            icon: const Icon(Icons.logout),
            onPressed: sair,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: novaLista,
        icon: const Icon(Icons.add),
        label: const Text(
          "Nova lista",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Conteudo(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text("Abertas (${abertas.length})"),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text("Sorteadas (${sorteadas.length})"),
                    ),
                  ],
                  selected: {verSorteadas},
                  onSelectionChanged: (s) =>
                      setState(() => verSorteadas = s.first),
                ),
              ),
            ),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: carregar,
                      child: visiveis.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 60),
                                EstadoVazio(
                                  icone: verSorteadas
                                      ? Icons.emoji_events_outlined
                                      : Icons.sports_soccer,
                                  titulo: verSorteadas
                                      ? "Nenhuma lista sorteada"
                                      : "Nenhuma lista aberta",
                                  texto: verSorteadas
                                      ? "As listas aparecem aqui depois do sorteio dos times."
                                      : "Crie uma lista, cadastre quem vai jogar e sorteie os times.",
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                              itemCount: visiveis.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final lista = visiveis[i];
                                return _CardLista(
                                  lista: lista,
                                  jogadores:
                                      jogadoresPorLista[lista["id"]] ??
                                      const [],
                                  podeExcluir:
                                      lista["cadastradoPor"] == usuario,
                                  onTap: () => abrir(lista),
                                  onExcluir: () => excluir(lista),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLista extends StatelessWidget {
  final Map<String, dynamic> lista;
  final List<dynamic> jogadores;
  final bool podeExcluir;
  final VoidCallback onTap;
  final VoidCallback onExcluir;

  const _CardLista({
    required this.lista,
    required this.jogadores,
    required this.podeExcluir,
    required this.onTap,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final sorteada = lista["sorteado"] == true;
    final goleiros = jogadores.where((j) => j["goleiro"] == true).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (sorteada ? esquema.onSurfaceVariant : esquema.primary)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  sorteada ? Icons.emoji_events_outlined : Icons.sports_soccer,
                  color: sorteada ? esquema.onSurfaceVariant : esquema.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lista["nome"] ?? "Sem nome",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        Etiqueta(
                          icone: Icons.event_outlined,
                          texto: formatarData(lista["data"]),
                        ),
                        Etiqueta(
                          icone: Icons.groups_outlined,
                          texto: "${jogadores.length} jogadores",
                        ),
                        Etiqueta(
                          icone: Icons.sports_handball_outlined,
                          texto: "$goleiros goleiros",
                          cor: goleiros > 0 ? Cores.goleiro : null,
                        ),
                        Etiqueta(
                          icone: Icons.person_outline,
                          texto: "${lista["jogadoresPorEquipe"]} por time",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (podeExcluir)
                IconButton(
                  tooltip: "Excluir lista",
                  icon: Icon(
                    Icons.delete_outline,
                    color: esquema.onSurfaceVariant,
                  ),
                  onPressed: onExcluir,
                )
              else
                Icon(Icons.chevron_right, color: esquema.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
