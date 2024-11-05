

import 'dart:convert';
import 'dart:typed_data';

class Pokemon {
  final int id;
  final String name; 
  final List<String> type; 
  Uint8List? img; 
  final Map<String, dynamic>? base; 

  Pokemon({
    required this.id,
    required this.name,
    required this.type,
    this.img,
    required this.base,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from((json['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
      img: null, 
      base: json['base'] as Map<String, dynamic>? ?? {},
    );
  }

  static String getPokemonImageUrl(int id) {
    final String formattedId = id.toString().padLeft(3, '0');
    return 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/$formattedId.png';
  }

  // Método para converter o Pokémon em um mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': {
        'english': name,
      },
      'type': jsonEncode(type),
      'img': img,
      'base': jsonEncode(base),
    };
  }
}

class PokeMapeando{
  static Pokemon fromJson(Map<String, dynamic> json, Uint8List? img) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from((json['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
      img: json['img'],
      base: json['base'] as Map<String, dynamic>? ?? {},
    );
  }
}