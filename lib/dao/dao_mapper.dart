import 'dart:convert';

import '../data/modelo_data.dart';
import 'dart:typed_data';

class PokeMapa {
  static Pokemon fromJson(Map<String, dynamic> json, [Uint8List? imageBytes]) {
  return Pokemon(
    id: json['id'] as int,
    name: json['name']['english'],
    type: List<String>.from((json['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
    img: imageBytes, // Deixa como null se a imagem não estiver disponível
    base: json['base'] as Map<String, dynamic>? ?? {},
  );
}

  static Map<String, dynamic> toMap(Pokemon pokemon) {
    return {
      'id': pokemon.id,
      'name': pokemon.name,
      'type': pokemon.type,
      'img': pokemon.img,
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
      'img': pokemon.img, // Armazena os bytes da imagem, se aplicável
      'base': jsonEncode(pokemon.base), // Serializa o mapa base
    };
  }

  static Pokemon fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      name: map['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from(jsonDecode(map['type'])),
      img: map['img'], // Pode ser necessário converter os bytes aqui, se aplicável
      base: jsonDecode(map['base']),
    );
  }

}