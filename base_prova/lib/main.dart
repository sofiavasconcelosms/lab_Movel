import 'package:flutter/material.dart';

import 'segunda_tela.dart';

void main() {
  runApp(const BaseProvaApp());
}

class BaseProvaApp extends StatelessWidget {
  const BaseProvaApp({super.key});

  static const Color corPrincipal = Color(0xFF315C72);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Base Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: corPrincipal),
        scaffoldBackgroundColor: const Color(0xFFF4F7F8),
        useMaterial3: true,
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final TextEditingController _textoController = TextEditingController();

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  void _abrirSegundaTela() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SegundaTela(texto: _textoController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base de estudos Flutter'),
        backgroundColor: BaseProvaApp.corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Widgets essenciais',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseProvaApp.corPrincipal,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Exemplos de entrada de texto, imagens, linhas, colunas e navegação.',
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/exemplo.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                            width: 96,
                            height: 96,
                            child: Icon(Icons.broken_image_outlined, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Image.asset exibe uma imagem local declarada no pubspec.yaml.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                      height: 160,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                        height: 160,
                        child: Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Image.network carrega uma imagem pela URL.'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textoController,
                decoration: const InputDecoration(
                  labelText: 'Digite um texto',
                  hintText: 'O texto será exibido na próxima tela',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _abrirSegundaTela(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _abrirSegundaTela,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Ir para a segunda tela'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
