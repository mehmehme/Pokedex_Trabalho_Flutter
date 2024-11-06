import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/estilos/fundoPokedex.dart';
import 'package:pokedex/repositorio/reposi_poke_impl.dart';
import 'package:pokedex/telas/meuPok.dart';
import 'package:pokedex/repositorio/reposi_poke.dart';
import 'package:provider/provider.dart';
import '../../data/modelo_data.dart';

class Time extends StatefulWidget {
  final List<int>? pokemons;

  const Time({
    super.key,
    this.pokemons,
  });

  @override
  State<Time> createState() => _TimeState();
}

class _TimeState extends State<Time> {
  late Future<Map<int, Pokemon>> pokemonMapFuture;
  late List<int> _currentPokemons;

  @override
  void initState() {
    super.initState();
    _currentPokemons = widget.pokemons ?? []; // Verificação do conteúdo
    pokemonMapFuture = _loadCapturedPokemons(); // Inicia o carregamento dos Pokémons
  }

  // Carrega os Pokémons usando o repositório
  Future<Map<int, Pokemon>> _loadCapturedPokemons() async {
    final pokemonRepository = context.read<PokemonRepositoryImpl>(); // Acessa o repositório via Provider
    return await pokemonRepository.getPokemons(); // Carrega os Pokémons do repositório
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
            onPressed: resetPokemons,
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
                  child: FutureBuilder<Map<int,Pokemon>>(
                    future: pokemonMapFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      } else {
                        final pokemonMap = snapshot.data!;

                        if (_currentPokemons.isEmpty) {
                          return Center(child: Text('Você ainda não capturou nenhum Pokémon.'));
                        }

                        return ListView.builder(
                          itemCount: _currentPokemons.length > 6 ? 6 : _currentPokemons.length,
                          itemBuilder: (context, index) {
                             final pokemonId = _currentPokemons[index];
                             final pokemon = pokemonMap[pokemonId];

                            if (pokemon == null) {
                              return ListTile(
                                title: Text("Pokémon não encontrado"),
                              );
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
                                  final currentTeam = _currentPokemons
                                      .map((id) => pokemonMap[id])
                                      .where((poke) => poke != null)
                                      .cast<Pokemon>()
                                      .toList();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeuPok(
                                        pokemonName: pokemon.name as String,
                                        pokemonId: pokemonId,
                                        team: currentTeam,
                                        onRelease: (id) {
                                          setState(() {
                                            _currentPokemons.removeWhere((pokeId) => pokeId == id);
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
                                      imageUrl: context.read<PokemonRepositoryImpl>().networkMapper.getPokemonImageUrl(pokemon.id),
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      pokemon.name as String,
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
                          }
                        );
                      }
                    }
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  ' ${_currentPokemons.length < 6 ? 6 - _currentPokemons.length : 0} espaço(s) restante(s)',
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
}
