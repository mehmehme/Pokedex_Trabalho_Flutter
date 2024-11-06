



class Pokemon {
  final int id;
  final String name; 
  final List<String> type; 
  String? imgUrl; 
  final Map<String, dynamic>? base; 

  Pokemon({
    required this.id,
    required this.name,
    required this.type,
    this.imgUrl,
    required this.base,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from((json['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
      base: json['base'] as Map<String, dynamic>? ?? {},
    );
  }

  // Método para converter o Pokémon em um mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': {
        'english': name,
      },
      'type': type,
      'img': imgUrl,
      'base': base,
    };
  }
}