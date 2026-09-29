import 'package:divisor_conta/data/contatos.dart';
import 'package:divisor_conta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantem exatamente cinco contatos pre-cadastrados', () {
    expect(contatos, hasLength(5));
    expect(contatos.map((contato) => contato.nome).toSet(), hasLength(5));
  });

  testWidgets('mostra foto, nome e telefone dos contatos', (tester) async {
    await tester.pumpWidget(const ListaContatosApp());

    expect(find.byType(ListTile), findsNWidgets(5));
    for (final contato in contatos) {
      expect(find.text(contato.nome), findsOneWidget);
      expect(find.text(contato.telefone), findsOneWidget);
    }
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CircleAvatar &&
            widget.backgroundImage is AssetImage &&
            widget.radius == 28,
      ),
      findsNWidgets(5),
    );
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('abre os detalhes com o nome do contato no AppBar', (
    tester,
  ) async {
    await tester.pumpWidget(const ListaContatosApp());

    await tester.tap(find.text('Camila Rocha'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Camila Rocha'),
      ),
      findsOneWidget,
    );
    expect(find.text('(31) 96543-2109'), findsOneWidget);
  });
}
