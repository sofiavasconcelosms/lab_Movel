import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lista_de_tarefas/models/tarefa.dart';
import 'package:lista_de_tarefas/screens/lista_tarefas_page.dart';
import 'package:lista_de_tarefas/services/tarefas_api.dart';

void main() {
  test('converte tarefa recebida da API', () {
    final tarefa = Tarefa.fromJson({
      'id': 7,
      'descricao': 'Estudar Flutter',
      'concluida': true,
    });

    expect(tarefa.id, 7);
    expect(tarefa.descricao, 'Estudar Flutter');
    expect(tarefa.concluida, isTrue);
    expect(tarefa.toJson()['concluida'], isTrue);
  });

  test('envia inclusao como JSON e retorna a tarefa persistida', () async {
    late http.Request requisicao;
    final api = TarefasApi(
      baseUrl: 'http://localhost:8000/',
      client: MockClient((request) async {
        requisicao = request;
        return http.Response(
          jsonEncode({
            'id': 12,
            'descricao': 'Estudar Flutter',
            'concluida': false,
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final tarefa = await api.criar('Estudar Flutter');

    expect(requisicao.method, 'POST');
    expect(requisicao.url.path, '/tarefas');
    expect(jsonDecode(requisicao.body), {'descricao': 'Estudar Flutter'});
    expect(tarefa.id, 12);
    api.close();
  });

  test('informa os erros retornados pela API', () async {
    final api = TarefasApi(
      baseUrl: 'http://localhost:8000',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'erro': 'Descricao invalida.'}),
          422,
        ),
      ),
    );

    await expectLater(
      api.criar(''),
      throwsA(isA<ApiException>().having(
        (erro) => erro.message,
        'message',
        'Descricao invalida.',
      )),
    );
    api.close();
  });

  testWidgets('adiciona, conclui e remove tarefas na lista', (tester) async {
    final registros = <Map<String, dynamic>>[];
    var proximoId = 1;
    final api = TarefasApi(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(jsonEncode(registros), 200);
        }
        if (request.method == 'POST') {
          final registro = <String, dynamic>{
            'id': proximoId++,
            'descricao':
                (jsonDecode(request.body) as Map<String, dynamic>)['descricao'],
            'concluida': false,
          };
          registros.insert(0, registro);
          return http.Response(jsonEncode(registro), 201);
        }
        final id = int.parse(request.url.pathSegments.last);
        if (request.method == 'PATCH') {
          final registro = registros.firstWhere((item) => item['id'] == id);
          registro['concluida'] =
              (jsonDecode(request.body) as Map<String, dynamic>)['concluida'];
          return http.Response(jsonEncode(registro), 200);
        }
        registros.removeWhere((item) => item['id'] == id);
        return http.Response('', 204);
      }),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      MaterialApp(home: ListaTarefasPage(api: api)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tudo em dia!'), findsOneWidget);

    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Estudar Flutter');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('Estudar Flutter'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await tester.tap(find.byTooltip('Remover Estudar Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Tudo em dia!'), findsOneWidget);
    expect(registros, isEmpty);
  });
}
