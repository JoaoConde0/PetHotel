class Tutor {
  final int? id;
  final String nome;
  final String contato;
  final String sexo;
  final String metodoPagamento;

  Tutor({
    this.id,
    required this.nome,
    required this.contato,
    required this.sexo,
    required this.metodoPagamento,
  });

  // Converte um objeto Tutor em um Map. Útil para inserir no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'contato': contato,
      'sexo': sexo,
      'metodoPagamento': metodoPagamento,
    };
  }

  // Converte um Map em um objeto Tutor. Útil para ler do banco de dados.
  factory Tutor.fromMap(Map<String, dynamic> map) {
    return Tutor(
      id: map['id'],
      nome: map['nome'],
      contato: map['contato'],
      sexo: map['sexo'],
      metodoPagamento: map['metodoPagamento'],
    );
  }
}