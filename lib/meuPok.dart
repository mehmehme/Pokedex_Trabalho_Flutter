import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/data/servicoPoke.dart' as servicPoke;

class MeuPok extends StatelessWidget {
  final String pokemonName;
  final int pokemonId;
  final List<Pokemon> team;
  final Function(int) onRelease;

  const MeuPok({
    super.key,
    required this.pokemonName,
    required this.pokemonId,
    required this.team,
    required this.onRelease,
  });

  Future<Pokemon> _fetchPokemonData() async {
  // Verifica a conectividade
  var connectivityResult = await Connectivity().checkConnectivity();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  if (connectivityResult == ConnectivityResult.none) {
    // Sem internet, carregue do cache
    String? cachedData = prefs.getString('pokemon_$pokemonId');
    if (cachedData != null) {
      return Pokemon.fromJson(jsonDecode(cachedData));
    } else {
      throw Exception('Dados do Pokémon não encontrados no cache.');
    }
  } else {
    // Conectado, carregue da API e armazene no cache
      Pokemon pokemon = await servicPoke.PokemonService.fetchPokemonDetails(pokemonName);
      prefs.setString('pokemon_$pokemonId', jsonEncode(pokemon.toJson()));
      return pokemon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 177, 53, 53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          pokemonName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<Pokemon>(
        future: _fetchPokemonData(),
        builder: (context, snapshot) {//espera a conecção
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else {
            final pokemon = snapshot.data!;
            return Stack(
              children: [
                Image.asset(
                  'assets/images/fundo2.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 80.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 119, 10, 38),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            width: 8,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: servicPoke.PokemonService.getPokemonImageUrl(pokemonId),
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: 250,
                        height: 450,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 119, 10, 38),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            width: 8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              pokemon.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              'Tipo: ${pokemon.type.join(', ')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'Informações Básicas',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            for (var key in pokemon.base.keys)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$key: ${pokemon.base[key]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: pokemon.base[key] / 100,
                                    backgroundColor: Colors.white54,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                fixedSize: Size(MediaQuery.of(context).size.width * 0.6,
                                    MediaQuery.of(context).size.height * 0.1),
                                backgroundColor: const Color.fromARGB(255, 167, 57, 57),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 223, 121, 121),
                                  width: 6,
                                ),
                              ),
                              onPressed: () {
                                onRelease(pokemonId);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pokémon liberado!'),
                                    duration: Duration(seconds: 6),
                                  ),
                                );
                              },
                              child: const Text(
                                'Soltar',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 248, 248),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
