import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PokemonService {
  static const String baseUrl = 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/pokedex.json';
  static const int limit = 15;

//pega os detalhes dos pokemons apartir do nome
    static Future<Pokemon> fetchPokemonDetails(String pokemonName) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> allPokemons = json.decode(response.body);
        // Filtra o Pokémon pelo nome
        for (var pokemon in allPokemons) {
          if (pokemon['name']['english'].toLowerCase() == pokemonName.toLowerCase()) {
            // Retorna o Pokémon encontrado
            return Pokemon.fromJson(pokemon);
          }
        }
        throw Exception('Pokémon não encontrado');
      } else {
        throw Exception('Erro ao carregar detalhes do Pokémon');
      }
    } catch (e) {
      print('Erro ao carregar detalhes do Pokémon: $e');
      throw e; // Re-throw para ser tratado pelo FutureBuilder
    }
  }
  // Função para buscar todos os dados de Pokémon
  static Future<List> fetchAllPokemons() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        _saveCache(response.body); // Salvar em cache
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((pokemonJson) => Pokemon.fromJson(pokemonJson)).toList();
      } else {
        throw Exception('Erro ao carregar JSON');
      }
    } catch (e) {
      return await _loadCache(); // Carregar do cache em caso de erro
    }
  }

  // Função para obter a URL da imagem de um Pokémon pelo número
  static String getPokemonImageUrl(int id) {
    final String formattedId = id.toString().padLeft(3, '0');
    return 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/$formattedId.png';
  }

  // Função para salvar dados em cache
  static Future<void> _saveCache(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedPokemons', data);
  }

  // Função para carregar dados do cache
  static Future<List<dynamic>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('cachedPokemons');

    if (cachedData != null) {
      return json.decode(cachedData);
    } else {
      return []; // Retornar lista vazia se não houver cache
    }
  }
  // Cacheia a lista de Pokémon
  static Future<void> _cachePokemons(List<Pokemon> pokemons) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedPokemons', json.encode(pokemons.map((p) => p.toJson()).toList()));
  }

  static Future<Map<String, dynamic>> getPokemonById(int id) async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar Pokémon');
    }
  }

}


