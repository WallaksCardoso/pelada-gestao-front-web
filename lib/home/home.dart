import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final assinatura =
        "${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year} - Wallaks Cardoso";

    return Scaffold(
      appBar: AppBar(title: const Text("Pelada Gestão")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/cadastroSorteio"),
              child: const Text("Novo Sorteio"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/sorteiosEmAndamento"),
              child: const Text("Sorteios em Andamento"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/sorteiosAnteriores"),
              child: const Text("Sorteios Anteriores"),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, "/login"),
              child: const Text("Sair"),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                assinatura,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
