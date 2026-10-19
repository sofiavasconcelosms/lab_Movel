class Tarefa {
  const Tarefa({
    required this.id,
    required this.descricao,
    required this.concluida,
  });

  final int id;
  final String descricao;
  final bool concluida;

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'] as int,
      descricao: json['descricao'] as String,
      concluida: json['concluida'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'descricao': descricao,
    'concluida': concluida,
  };
}
