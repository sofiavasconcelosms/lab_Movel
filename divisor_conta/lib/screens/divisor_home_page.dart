import 'package:flutter/material.dart';

import '../models/divisao_conta.dart';
import '../utils/formatador.dart';
import '../widgets/campo_numerico.dart';

class DivisorHomePage extends StatefulWidget {
  const DivisorHomePage({super.key});
  @override
  State<DivisorHomePage> createState() => _DivisorHomePageState();
}

class _DivisorHomePageState extends State<DivisorHomePage> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controllerConta = TextEditingController();
  final _controllerPessoas = TextEditingController(text: '2');
  final _controllerGorjeta = TextEditingController(text: '10');

  double _percentualGorjetaSlider = 10.0;
  DivisaoConta? _resultado;

  @override
  void initState() {
    super.initState();
    _controllerGorjeta.addListener(_escutarGorjeta);
  }

  @override
  void dispose() {
    _controllerGorjeta.removeListener(_escutarGorjeta);
    _controllerConta.dispose();
    _controllerPessoas.dispose();
    _controllerGorjeta.dispose();
    super.dispose();
  }

  void _escutarGorjeta() {
    final numero = paraDouble(_controllerGorjeta.text);
    if (numero != null) {
      final valorComClamp = numero.clamp(0.0, 25.0);
      if (_percentualGorjetaSlider != valorComClamp) {
        setState(() {
          _percentualGorjetaSlider = valorComClamp;
        });
      }
    }
  }

  void _calcular() {
    if (!_chaveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final conta = paraDouble(_controllerConta.text)!;
    final pessoas = int.parse(_controllerPessoas.text.trim());
    final gorjeta = paraDouble(_controllerGorjeta.text)!;
    setState(() {
      _resultado = DivisaoConta(
        valorConta: conta,
        quantidadePessoas: pessoas,
        percentualGorjeta: gorjeta,
      );
    });
  }

  void _limpar() {
    _chaveFormulario.currentState!.reset();
    _controllerConta.clear();
    _controllerPessoas.text = '2';
    _controllerGorjeta.text = '10';
    setState(() {
      _percentualGorjetaSlider = 10.0;
      _resultado = null;
    });
  }

  String? _validarConta(String? valor) {
    final numero = paraDouble(valor ?? '');
    if (numero == null) return 'Informe o valor da conta';
    if (numero <= 0) return 'O valor deve ser maior que zero';
    return null;
  }

  String? _validarPessoas(String? valor) {
    final numero = int.tryParse((valor ?? '').trim());
    if (numero == null) return 'Informe a quantidade de pessoas';
    if (numero < 1) return 'Deve haver pelo menos 1 pessoa';
    if (numero > 100) return 'Máximo de 100 pessoas';
    return null;
  }

  String? _validarGorjeta(String? valor) {
    final numero = paraDouble(valor ?? '');
    if (numero == null) return 'Informe a porcentagem (use 0 se não houver)';
    if (numero < 0) return 'A gorjeta não pode ser negativa';
    if (numero > 25) return 'A gorjeta não pode passar de 25%';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicativo divide conta'),
        actions: [
          IconButton(
            onPressed: _limpar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Caixa 1: Valor total da conta
                Card(
                  elevation: 0,
                  color: tema.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: tema.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              color: tema.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Valor total da conta',
                              style: tema.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CampoNumerico(
                          controller: _controllerConta,
                          rotulo: 'Digite o valor total',
                          icone: Icons.attach_money,
                          sufixo: 'R\$',
                          validador: _validarConta,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Caixa 2: Quantidade de pessoas
                Card(
                  elevation: 0,
                  color: tema.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: tema.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.groups,
                              color: tema.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quantidade de pessoas',
                              style: tema.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CampoNumerico(
                          controller: _controllerPessoas,
                          rotulo: 'Número de pessoas',
                          icone: Icons.person,
                          apenasInteiros: true,
                          validador: _validarPessoas,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Caixa 3: Gorjeta do garçom
                Card(
                  elevation: 0,
                  color: tema.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: tema.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.room_service,
                                  color: tema.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Gorjeta do garçom',
                                  style: tema.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_percentualGorjetaSlider.toStringAsFixed(0)}%',
                              style: tema.textTheme.titleMedium?.copyWith(
                                color: tema.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _percentualGorjetaSlider,
                          min: 0,
                          max: 25,
                          divisions: 25,
                          label: '${_percentualGorjetaSlider.round()}%',
                          onChanged: (novoValor) {
                            setState(() {
                              _percentualGorjetaSlider = novoValor;
                              _controllerGorjeta.text =
                                  novoValor.round().toString();
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        CampoNumerico(
                          controller: _controllerGorjeta,
                          rotulo: 'Digite a porcentagem (máx 25%)',
                          icone: Icons.edit,
                          sufixo: '%',
                          validador: _validarGorjeta,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calcular'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                if (_resultado != null) _CartaoResultado(divisao: _resultado!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaoResultado extends StatelessWidget {
  const _CartaoResultado({required this.divisao});
  final DivisaoConta divisao;
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      elevation: 0,
      color: tema.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Resultado', style: tema.textTheme.titleMedium),
            const Divider(height: 24),
            _LinhaResultado(
              rotulo: 'Parte do garçom',
              valor: formatarReal(divisao.valorGorjeta),
            ),
            const SizedBox(height: 12),
            _LinhaResultado(
              rotulo: 'Total a pagar (conta + gorjeta)',
              valor: formatarReal(divisao.valorTotalAPagar),
            ),
            const SizedBox(height: 12),
            _LinhaResultado(
              rotulo: 'Cada pessoa paga',
              valor: formatarReal(divisao.valorPorPessoa),
              destaque: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaResultado extends StatelessWidget {
  const _LinhaResultado({
    required this.rotulo,
    required this.valor,
    this.destaque = false,
  });
  final String rotulo;
  final String valor;
  final bool destaque;
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estiloValor = destaque
        ? tema.textTheme.headlineSmall?.copyWith(
            color: tema.colorScheme.primary,
            fontWeight: FontWeight.bold,
          )
        : tema.textTheme.titleMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: Text(rotulo, style: tema.textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Text(valor, style: estiloValor),
      ],
    );
  }
}