class Raca {
  final int? id;
  final String nome;
  final String especie; // "Cachorro" ou "Gato"

  Raca({
    this.id,
    required this.nome,
    required this.especie,
  });

  // Converte um objeto Raca em um Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'especie': especie,
    };
  }

  // Converte um Map em um objeto Raca.
  factory Raca.fromMap(Map<String, dynamic> map) {
    return Raca(
      id: map['id'],
      nome: map['nome'],
      especie: map['especie'],
    );
  }
}