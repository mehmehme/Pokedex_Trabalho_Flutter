import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/data/servicoPoke.dart' as servicPoke;

class Pokemon {
  final int id;
  final String name; // nome do Pokemon
  final List<String> type; // tipos do Pokemon
  final String imageUrl; // URL da imagem do Pokemon
  final Map<String, dynamic> base; // atributos básicos

  Pokemon({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.base,
  });

  // Método para criar um Pokémon a partir de um mapa evitando erro por ser nulo por que o codigo decidiu
  //que isso era o maior problema
  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      name: map['name']['english'] ?? 'Nome não disponível', // Use um valor padrão se o nome for nulo
      type: List<String>.from(map['type'] ?? []), // Use uma lista vazia se o tipo for nulo
      imageUrl: map['img'] ?? '', // Use uma string vazia se a imagem for nula
      base: map['base'] as Map<String, dynamic>? ?? {}, // Use um mapa vazio se base for nulo
    );
  }

  // Método para carregar o mapa de Pokémons
  static Future<Map<int, Pokemon>> loadPokemonMap() async {
    final url = 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/pokedex.json'; // URL do seu JSON

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return {
        for (var pokemon in data)
          pokemon['id']: Pokemon.fromMap(pokemon), // Mapeia cada Pokémon pelo seu ID
      };
    } else {
      throw Exception('Falha ao carregar Pokémons');
    }
  }

  // Método para converter o Pokémon em JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name']['english'] ?? 'Nome não disponível', // Verificação para evitar nulo
      type: List<String>.from(json['type'] ?? []), // Verificação para evitar nulo
      imageUrl: servicPoke.PokemonService.getPokemonImageUrl(json['id']), // URL da imagem
      base: json['base'] as Map<String, dynamic>? ?? {}, // Use um mapa vazio se base for nulo
    );
  }

  // Método para converter o Pokémon em um mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {
        'english': name,
      },
      'type': type,
      'img': imageUrl, // Certifique-se de que este é o campo correto
      'base': base,
    };
  }
}
