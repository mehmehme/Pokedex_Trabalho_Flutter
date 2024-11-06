/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/estilos/fundoPokedex.dart';
import 'package:pokedex/telas/meuPok.dart';
import 'package:pokedex/repositorio/reposi_poke.dart';
import 'package:provider/provider.dart';
import '../../dao/pokemon_dao.dart';
import '../../network/net_poke.dart';
import '../../data/modelo_data.dart';

class Time extends StatefulWidget {
  final List<int>? pokemons; // Recebe a lista de Pokémon capturados

  const Time({
    super.key,
    this.pokemons,
  });

  @override
  State<Time> createState() => _TimeState();
}

class _TimeState extends State<Time> {
  late final Future<List<Pokemon>> pokemonMap;
  late List<int?> _currentPokemons;
  late PokemonRepository pokemonRepository;

  @override
  void initState() { 
    super.initState();
   _currentPokemons = (widget.pokemons ?? []).map((id) {
      if (id is String) {
        int? parsedId = int.tryParse(id as String);
        if (parsedId != null) {
          return parsedId;
        } else {
          // Remove invalid ID if conversion fails
          print("Invalid ID: $id. Removing from _currentPokemons");
          return null;
        }
      }
      return id; // If already an int, return it
    }).toList();
    

    // Inicializa o repositório de Pokémon
    pokemonRepository = PokemonRepository(
      pokemonDao: PokemonDao(), // Supondo que você tenha uma instância de PokemonDao
      pokemonNetwork: PokemonNetwork(), // Supondo que você tenha uma instância de PokemonNetwork
    );

    // Carrega a lista de Pokémon capturados usando o repositório
    pokemonMap = _loadCapturedPokemons();
  }

  Future<List<Pokemon>> _loadCapturedPokemons() async {
    return await pokemonRepository.getPokemons(); // Chama o método do repositório
  }

  void resetPokemons() {
    setState(() {
      _currentPokemons.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 86, 75, 151),
                Color.fromARGB(255, 47, 25, 87)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Seu time',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.refresh),
            onPressed: resetPokemons, // Chama o método de reinicialização
          ),
        ],
      ),
      body: Stack(
        children: [
          fundoGradiente(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<Pokemon>>(
                    future: pokemonMap,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print('Erro ao carregar os Pokémons: ${snapshot.error}');
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      } else {
                        final pokemonMap = snapshot.data!;

                        if (_currentPokemons.isEmpty) {
                          return Center(child: Text('Você ainda não capturou nenhum Pokémon.'));
                        }

                        return ListView.builder(
                          itemCount: _currentPokemons.length > 6 ? 6 : _currentPokemons.length,
                          itemBuilder: (context, index) {
                            final pokemonIdString = _currentPokemons[index];
                            int? pokemonId = int.tryParse(pokemonIdString as String);
                            final pokemon = pokemonMap.firstWhere(
                              (poke) => poke.id == pokemonId,
                              orElse: () => Pokemon(id: -1, name: 'Desconhecido', type: [], base: {}),
                              );

                            if (pokemon == null) {
                              return Center(
                                child: const Text(
                                  "Não há ninguém aqui!",
                                  style: const TextStyle(
                                        color: Color.fromARGB(255, 71, 26, 71),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                ),
                              ); // Ou uma mensagem de erro
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 77, 70, 141),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color.fromARGB(255, 39, 53, 100), width: 4),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  final currentTeam = _currentPokemons.map((id) => pokemonMap.firstWhere((poke) => poke.id == id)).toList();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeuPok(
                                        pokemonName: pokemon.name,
                                        pokemonId: pokemon.id,
                                        team: currentTeam,
                                        onRelease: (id) {
                                          setState(() {
                                            _currentPokemons.removeWhere((pokemonId) => pokemonId == id);
                                          });
                                        },
                                        pokemonRepository: Provider.of<PokemonRepository>(context, listen: false),
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: const Color.fromARGB(255, 147, 146, 240),
                                  margin: EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    leading: CachedNetworkImage(
                                      imageUrl: context.read<PokemonRepository>().pokemonNetwork.getPokemonImageUrl(pokemon.id),
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      pokemon.name,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Tipo: ${pokemon.type.join(', ')}',
                                      style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  '${_currentPokemons.length < 6 ? 6 - _currentPokemons.length : 0} espaço(s) restante(s)',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
