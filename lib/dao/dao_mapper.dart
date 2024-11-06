import 'dart:convert';
import '../data/modelo_data.dart';

class PokeMapa {
  static Pokemon fromJson(Map<String, dynamic> json) {
  return Pokemon(
    id: json['id'] as int,
    name: json['name']['english'],
    type: List<String>.from((json['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
    base: json['base'] as Map<String, int>? ?? {},
  );
}

  static Map<String, dynamic> toMap(Pokemon pokemon) {
    return {
      'id': pokemon.id,
      'name': pokemon.name,
      'type': pokemon.type,
      'img': pokemon.imgUrl,
      'base': pokemon.base,
    };
  }
}

class Mapinha{
  static Map<String, dynamic> toMap(Pokemon pokemon) {
    return {
      'id': pokemon.id,
      'name': {
        'english': pokemon.name,
      },
      'type': jsonEncode(pokemon.type), // Serializa a lista de tipos
      'img': pokemon.imgUrl, // Armazena os bytes da imagem, se aplicável
      'base': jsonEncode(pokemon.base), // Serializa o mapa base
    };
  }

  static Pokemon fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      name: map['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from(jsonDecode(map['type'])),
      imgUrl: map['img'],
      base: jsonDecode(map['base']),
    );
  }

}