import 'package:flutter/material.dart';

import '../models/contato.dart';

class DetalheContatoPage extends StatelessWidget {
  const DetalheContatoPage({required this.contato, super.key});

  final Contato contato;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(contato.nome)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundColor: tema.colorScheme.secondaryContainer,
                backgroundImage: AssetImage(contato.imagem),
                child: Semantics(
                  label: 'Foto de ${contato.nome}',
                  image: true,
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                contato.nome,
                style: tema.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                contato.telefone,
                style: tema.textTheme.titleMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
