import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pokedex/network/net_mapper.dart';
import '../data/modelo_data.dart';


class PokemonNetwork {
  final url = 'http://192.168.0.23:3000/pokemon';

  Future<List<Pokemon>> fetchPokemonList() async {
    print("Fetching Pokémon list from $url");
    final response = await http.get(Uri.parse(url));
    
    print("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Pokemon> pokemons = NetMapa.fromJsonList(data); // Usando o mapper

      for (var json in data) {
            pokemons.add(Pokemon.fromJson(json));
      }
      // Carrega a imagem para cada Pokémon
      for (var pokemon in pokemons) {
        pokemon.img = await _fetchPokemonImage(pokemon.id);
      }

      return pokemons;
    } else {
      throw Exception('Failed to load Pokémons');
    }
  }

  Future<Uint8List?> _fetchPokemonImage(int id) async {
    final imageUrl = getPokemonImageUrl(id);
    final imgResponse = await http.get(Uri.parse(imageUrl));

    if (imgResponse.statusCode == 200) {
      return imgResponse.bodyBytes; // Retorna os bytes da imagem
    }
    return null; // Se não conseguir, retorna null
  }

  String getPokemonImageUrl(int id) {
    return 'http://192.168.0.23:3000/pokemon${id.toString().padLeft(3, '0')}.png'; // URL correta
  }
}
