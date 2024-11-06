import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/modelo_data.dart';

class PokemonNetwork {
  final url = 'http://192.168.0.23:3000/pokemon';

  Future<Map<int, Pokemon>> fetchPokemonList() async {
    print("Fetching Pokémon list from $url");
    final response = await http.get(Uri.parse(url));

    print("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      Map<int, Pokemon> pokemons = {
        for (var json in data)
          json['id'] as int: Pokemon.fromJson(json)
      };

      // Define o URL da imagem para cada Pokémon
      for (var entry in pokemons.entries) {
        entry.value.imgUrl = getPokemonImageUrl(entry.key);
      }

      return pokemons;
    } else {
      throw Exception('Failed to load Pokémons');
    }
  }

  String getPokemonImageUrl(int id) {
    return 'http://192.168.0.23:3000/pokemon${id.toString().padLeft(3, '0')}.png';
  }
}
