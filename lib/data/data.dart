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

  // Método para criar um Pokémon a partir de um mapa evitando erro por ser nulo por que o codigo decidiu
  //que isso era o maior problema
  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      name: map['name']['english'] ?? 'Nome não disponível', 
      type: (map['type'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[], 
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
          pokemon['id'] as int: Pokemon.fromMap(pokemon),
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
  
  // Tente obter o cache salvo
  final String? cachedData = prefs.getString('pokemon_cache');
  
  if (cachedData != null) {
    // Decode o JSON e mapeia os dados para Map<int, Pokemon>
    final List<dynamic> dataList = json.decode(cachedData);
    
    // Converte a lista de mapas em um Map<int, Pokemon>
    final Map<int, Pokemon> pokemonMap = {
      for (var pokemonData in dataList)
        (pokemonData['id'] as int): Pokemon.fromMap(pokemonData as Map<String, dynamic>),
    };

    return pokemonMap;
  }
  
  // Retorna um mapa vazio se não houver dados no cache
  return {};
}

  static Future<void> _saveCacheData(Map<int, Pokemon> pokemonMap) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Converte o mapa de Pokémon em uma lista de mapas (para poder converter para JSON)
    final List<Map<String, dynamic>> pokemonList = 
        pokemonMap.values.map((pokemon) => pokemon.toJson()).toList();
    
    // Salva a lista como uma string JSON
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
      id: json['id'],
      name: json['name']['english'] ?? 'Nome não disponível', 
      type: (json['type'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[], 
      imageUrl: servicPoke.PokemonService.getPokemonImageUrl(json['id']), 
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
      'img': imageUrl, // Certifique-se de que este é o campo correto
      'base': base,
    };
  }
}
