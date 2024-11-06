class Pokemon {
  final int id;
  final Map<String,String> name; 
  final List<String> type; 
  String? imgUrl; 
  final Map<String, int>? base; 

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
      name: json['name']['english'],
      type: List<String>.from((json['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
      base: json['base'] as Map<String, int>? ?? {},
    );
  }

  // Método para converter o Pokémon em um mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': {
        'english': name['english'],
      },
      'type': type,
      'img': imgUrl,
      'base': base,
    };
  }
}