import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/tarefa.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TarefasApi {
  TarefasApi({
    String? baseUrl,
    http.Client? client,
  }) : _baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'http://10.0.2.2:8000',
           ),
       _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Uri _uri(String caminho) =>
      Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/+$'), '')}/$caminho');

  Future<List<Tarefa>> listar() async {
    final resposta = await _client.get(_uri('tarefas'));
    _verificarResposta(resposta);
    final dados = jsonDecode(resposta.body) as List<dynamic>;
    return dados
        .map((item) => Tarefa.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Tarefa> criar(String descricao) async {
    final resposta = await _client.post(
      _uri('tarefas'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'descricao': descricao}),
    );
    _verificarResposta(resposta);
    return Tarefa.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<Tarefa> atualizarConclusao(Tarefa tarefa, bool concluida) async {
    final resposta = await _client.patch(
      _uri('tarefas/${tarefa.id}'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'concluida': concluida}),
    );
    _verificarResposta(resposta);
    return Tarefa.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<void> remover(int id) async {
    final resposta = await _client.delete(_uri('tarefas/$id'));
    _verificarResposta(resposta);
  }

  void close() => _client.close();

  void _verificarResposta(http.Response resposta) {
    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return;
    }

    var mensagem = 'A solicitacao falhou (${resposta.statusCode}).';
    try {
      final dados = jsonDecode(resposta.body);
      if (dados is Map<String, dynamic> && dados['erro'] is String) {
        mensagem = dados['erro'] as String;
      }
    } on FormatException {
      // Usa a mensagem de status quando a resposta nao traz um JSON de erro.
    }
    throw ApiException(mensagem);
  }
}
