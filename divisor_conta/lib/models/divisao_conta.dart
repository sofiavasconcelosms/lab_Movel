class DivisaoConta {
  final double valorConta;
  final int quantidadePessoas;
  final double percentualGorjeta;
  const DivisaoConta({
    required this.valorConta,
    required this.quantidadePessoas,
    required this.percentualGorjeta,
  }) : assert(valorConta >= 0, 'O valor da conta não pode ser negativo'),
       assert(quantidadePessoas > 0, 'É preciso ao menos 1 pessoa'),
       assert(percentualGorjeta >= 0, 'A gorjeta não pode ser negativa');
  double get valorGorjeta => valorConta * (percentualGorjeta / 100);
  double get valorTotalAPagar => valorConta + valorGorjeta;
  double get valorPorPessoa => valorTotalAPagar / quantidadePessoas;
}
