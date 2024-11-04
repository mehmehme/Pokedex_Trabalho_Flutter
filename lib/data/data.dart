import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/data/servicoPoke.dart' as servicPoke;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Método para criar um Pokémon a partir de um mapa
  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'] as int,
      name: map['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from((map['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
      imageUrl: map['img'] ?? '',
      base: map['base'] as Map<String, dynamic>? ?? {},
    );
  }

  // Método para carregar o mapa de Pokémons
  static Future<Map<int, Pokemon>> loadPokemonMap() async {
    
    try {
      // Tente carregar os dados do cache primeiro
      final cacheData = await _loadCacheData();
      if (cacheData.isNotEmpty) {
        return cacheData; // Se o cache não estiver vazio, use-o
      }

      // Verifique se há conectividade de rede
      final hasInternet = await _hasInternetConnection();

      if (!hasInternet) {
        throw Exception("Sem conexão com a internet e cache vazio");
      }

      // Caso contrário, tente carregar da URL
      final url = 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/pokedex.json';
      final response = await http.get(Uri.parse(url));


      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<int, Pokemon> pokemonMap = {
          for (var pokemon in data) 
            pokemon['id'] as int: Pokemon.fromMap(pokemon as Map<String, dynamic>),
        };

        // Salve no cache para uso offline futuro
        await _saveCacheData(pokemonMap);

        return pokemonMap;
      } else {
        throw Exception('Falha ao carregar Pokémons da internet');
      }
    } catch (e) {
      throw Exception('Erro ao carregar dados: $e');
    }
  }

  static Future<Map<int, Pokemon>> _loadCacheData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('pokemon_cache');

    if (cachedData != null) {
      final List<dynamic> dataList = json.decode(cachedData);

      // Verifique se dataList é realmente uma lista
      return {
        for (var pokemonData in dataList)
          (pokemonData['id'] as int): Pokemon.fromMap(pokemonData as Map<String, dynamic>),
      };
        }
    return {}; // Retorna um mapa vazio se não houver dados no cache
  }

  static Future<void> _saveCacheData(Map<int, Pokemon> pokemonMap) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> pokemonList = 
        pokemonMap.values.map((pokemon) => pokemon.toJson()).toList();
    await prefs.setString('pokemon_cache', json.encode(pokemonList));
  }

  static Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Método para converter o Pokémon em JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from((json['type'] as List<dynamic>? ?? []).map((e) => e.toString())),
      imageUrl: servicPoke.PokemonService.getPokemonImageUrl(json['id'] as int), // Certifique-se de que id é um int
      base: json['base'] as Map<String, dynamic>? ?? {},
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
      'img': imageUrl,
      'base': base,
    };
  }
}
