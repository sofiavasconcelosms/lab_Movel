String formatarReal(double valor) {
final partes = valor.toStringAsFixed(2).split('.');
final inteiros = partes[0].replaceAllMapped(
RegExp(r'\B(?=(\d{3})+(?!\d))'),
(_) => '.',
);
return 'R\$ $inteiros,${partes[1]}';
}
double? paraDouble(String texto) {
var limpo = texto.trim();
if (limpo.isEmpty) return null;
if (limpo.contains(',')) {
limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
}
return double.tryParse(limpo);
}