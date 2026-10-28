import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

const timesDoResultado = [
  (chave: "timeAzul", titulo: "Time Azul", cor: Cores.azul),
  (chave: "timeVermelho", titulo: "Time Vermelho", cor: Cores.vermelho),
];

List<dynamic> _goleirosPrimeiro(List<dynamic>? jogadores) {
  final lista = [...?jogadores];
  lista.sort(
    (a, b) => (b["goleiro"] == true ? 1 : 0) - (a["goleiro"] == true ? 1 : 0),
  );
  return lista;
}

String textoDoResultado(
  String nomeLista,
  String data,
  Map<String, dynamic> resultado,
) {
  final linhas = <String>["$nomeLista - $data"];
  final grupos = [
    ...timesDoResultado.map((t) => (titulo: t.titulo, chave: t.chave)),
    (titulo: "Reservas", chave: "reservas"),
  ];
  for (final grupo in grupos) {
    final jogadores = _goleirosPrimeiro(resultado[grupo.chave]);
    if (jogadores.isEmpty && grupo.chave == "reservas") continue;
    linhas
      ..add("")
      ..add(grupo.titulo);
    for (final j in jogadores) {
      linhas.add("- ${j["nome"]}${j["goleiro"] == true ? " (goleiro)" : ""}");
    }
  }
  return linhas.join("\n");
}

class CardTime extends StatelessWidget {
  final String titulo;
  final Color cor;
  final List<dynamic>? jogadores;

  const CardTime({
    super.key,
    required this.titulo,
    required this.cor,
    required this.jogadores,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final lista = _goleirosPrimeiro(jogadores);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: cor),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  "${lista.length}",
                  style: TextStyle(
                    color: esquema.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (lista.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text(
                "Ninguém",
                style: TextStyle(color: esquema.onSurfaceVariant),
              ),
            ),
          for (final jogador in lista)
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                jogador["goleiro"] == true
                    ? Icons.sports_handball
                    : Icons.directions_run,
                size: 20,
                color: jogador["goleiro"] == true
                    ? Cores.goleiro
                    : esquema.onSurfaceVariant,
              ),
              title: Text(
                jogador["nome"] ?? "",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: jogador["goleiro"] == true
                  ? const Text(
                      "Goleiro",
                      style: TextStyle(
                        color: Cores.goleiro,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
