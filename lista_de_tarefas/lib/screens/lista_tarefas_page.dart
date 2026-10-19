import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/tarefas_api.dart';

class ListaTarefasPage extends StatefulWidget {
  const ListaTarefasPage({super.key, TarefasApi? api})
    : _api = api;

  final TarefasApi? _api;

  @override
  State<ListaTarefasPage> createState() => _ListaTarefasPageState();
}

class _ListaTarefasPageState extends State<ListaTarefasPage> {
  late final TarefasApi _api = widget._api ?? TarefasApi();
  final List<Tarefa> _tarefas = [];
  final Set<int> _emAtualizacao = {};
  Object? _erro;
  bool _carregando = true;
  bool _criando = false;

  @override
  void initState() {
    super.initState();
    unawaited(_carregar());
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final tarefas = await _api.listar();
      if (mounted) {
        setState(() {
          _tarefas
            ..clear()
            ..addAll(tarefas);
          _carregando = false;
        });
      }
    } on Object catch (erro) {
      if (mounted) {
        setState(() {
          _erro = erro;
          _carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget._api == null) {
      _api.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
        centerTitle: false,
      ),
      body: SafeArea(child: _buildBody(tema)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criando || _carregando ? null : _adicionar,
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  Widget _buildBody(ThemeData tema) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return _ErroCarregamento(
        mensagem: _erro.toString(),
        aoTentarNovamente: _carregar,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
      children: [
        Text(
          'Organize seu dia',
          style: tema.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _tarefas.isEmpty
              ? 'Adicione uma tarefa para começar.'
              : '${_tarefas.where((tarefa) => tarefa.concluida).length} '
                    'de ${_tarefas.length} '
                    '${_tarefas.length == 1 ? 'tarefa concluída' : 'tarefas concluídas'}',
          style: tema.textTheme.bodyLarge?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        if (_tarefas.isEmpty)
          const _ListaVazia()
        else
          for (final tarefa in _tarefas) ...[
            _CartaoTarefa(
              tarefa: tarefa,
              carregando: _emAtualizacao.contains(tarefa.id),
              aoAlterarConclusao: (concluida) =>
                  _alterarConclusao(tarefa, concluidas: concluida),
              aoRemover: () => _remover(tarefa),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Future<void> _adicionar() async {
    final descricao = await showDialog<String>(
      context: context,
      builder: (context) => const _DialogNovaTarefa(),
    );
    if (descricao == null || !mounted) {
      return;
    }

    setState(() => _criando = true);
    try {
      final tarefa = await _api.criar(descricao);
      if (!mounted) {
        return;
      }
      setState(() {
        _tarefas.insert(0, tarefa);
        _erro = null;
        _carregando = false;
        _criando = false;
      });
    } on Object catch (erro) {
      if (mounted) {
        setState(() => _criando = false);
        _mostrarErro(erro);
      }
    }
  }

  Future<void> _alterarConclusao(
    Tarefa tarefa, {
    required bool concluidas,
  }) async {
    setState(() => _emAtualizacao.add(tarefa.id));
    try {
      final atualizada = await _api.atualizarConclusao(tarefa, concluidas);
      if (!mounted) {
        return;
      }
      setState(() {
        final indice = _tarefas.indexWhere((item) => item.id == tarefa.id);
        if (indice >= 0) {
          _tarefas[indice] = atualizada;
        }
        _emAtualizacao.remove(tarefa.id);
      });
    } on Object catch (erro) {
      if (mounted) {
        setState(() => _emAtualizacao.remove(tarefa.id));
        _mostrarErro(erro);
      }
    }
  }

  Future<void> _remover(Tarefa tarefa) async {
    setState(() => _emAtualizacao.add(tarefa.id));
    try {
      await _api.remover(tarefa.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _tarefas.removeWhere((item) => item.id == tarefa.id);
        _emAtualizacao.remove(tarefa.id);
      });
    } on Object catch (erro) {
      if (mounted) {
        setState(() => _emAtualizacao.remove(tarefa.id));
        _mostrarErro(erro);
      }
    }
  }

  void _mostrarErro(Object erro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Não foi possível concluir: $erro')),
    );
  }
}

class _CartaoTarefa extends StatelessWidget {
  const _CartaoTarefa({
    required this.tarefa,
    required this.carregando,
    required this.aoAlterarConclusao,
    required this.aoRemover,
  });

  final Tarefa tarefa;
  final bool carregando;
  final ValueChanged<bool> aoAlterarConclusao;
  final VoidCallback aoRemover;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: tema.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Checkbox(
          value: tarefa.concluida,
          onChanged: carregando
              ? null
              : (valor) {
                  if (valor != null) {
                    aoAlterarConclusao(valor);
                  }
                },
        ),
        title: Text(
          tarefa.descricao,
          style: tema.textTheme.titleMedium?.copyWith(
            decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
            color: tarefa.concluida
                ? tema.colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        trailing: IconButton(
          tooltip: 'Remover ${tarefa.descricao}',
          onPressed: carregando ? null : aoRemover,
          icon: carregando
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 64,
            color: tema.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text('Tudo em dia!', style: tema.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Suas tarefas aparecerão aqui.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  const _ErroCarregamento({
    required this.mensagem,
    required this.aoTentarNovamente,
  });

  final String mensagem;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('Não foi possível carregar as tarefas.'),
            const SizedBox(height: 4),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: aoTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogNovaTarefa extends StatefulWidget {
  const _DialogNovaTarefa();

  @override
  State<_DialogNovaTarefa> createState() => _DialogNovaTarefaState();
}

class _DialogNovaTarefaState extends State<_DialogNovaTarefa> {
  final _controlador = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _salvar() {
    final descricao = _controlador.text.trim();
    if (descricao.isEmpty) {
      setState(() => _erro = 'Digite a descrição da tarefa.');
      return;
    }
    if (descricao.runes.length > 255) {
      setState(() => _erro = 'Use no máximo 255 caracteres.');
      return;
    }
    Navigator.of(context).pop(descricao);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova tarefa'),
      content: TextField(
        controller: _controlador,
        autofocus: true,
        maxLength: 255,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'O que você precisa fazer?',
          errorText: _erro,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _salvar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvar,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
