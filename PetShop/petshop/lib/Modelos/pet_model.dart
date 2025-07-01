class Pet {
  final int? id;
  final int tutorId;
  final int racaId;
  final String especie;
  final String dataEntrada;
  final String? dataSaida; // Pode ser nula

  Pet({
    this.id,
    required this.tutorId,
    required this.racaId,
    required this.especie,
    required this.dataEntrada,
    this.dataSaida,
  });

  // Converte um objeto Pet em um Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorId': tutorId,
      'racaId': racaId,
      'especie': especie,
      'dataEntrada': dataEntrada,
      'dataSaida': dataSaida,
    };
  }

  // Converte um Map em um objeto Pet.
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      tutorId: map['tutorId'],
      racaId: map['racaId'],
      especie: map['especie'],
      dataEntrada: map['dataEntrada'],
      dataSaida: map['dataSaida'],
    );
  }
}