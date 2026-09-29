import 'package:flutter/material.dart';

import '../data/contatos.dart';
import '../models/contato.dart';
import 'detalhe_contato_page.dart';

class ListaContatosPage extends StatelessWidget {
  const ListaContatosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contatos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              'Sua agenda',
              style: tema.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Seus contatos favoritos em um só lugar.',
              style: tema.textTheme.bodyLarge?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            for (final contato in contatos) ...[
              _CartaoContato(contato: contato),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartaoContato extends StatelessWidget {
  const _CartaoContato({required this.contato});

  final Contato contato;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: tema.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: tema.colorScheme.secondaryContainer,
          backgroundImage: AssetImage(contato.imagem),
          child: Semantics(
            label: 'Foto de ${contato.nome}',
            image: true,
            child: const SizedBox.expand(),
          ),
        ),
        title: Text(
          contato.nome,
          style: tema.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(contato.telefone),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: tema.colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalheContatoPage(contato: contato),
            ),
          );
        },
      ),
    );
  }
}
