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

  static Map<String, dynamic> toDb(Pokemon pokemon) {
    return {
      'id': pokemon.id,
      'name': pokemon.name,
      'type': pokemon.type,
      'img': pokemon.img,
      'base': pokemon.base != null ? jsonEncode(pokemon.base) : null,
    };
  }
}