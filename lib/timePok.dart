// Time.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/data/data.dart'; // Ajuste a importação
import 'package:pokedex/estilos/fundoPokedex.dart';
import 'package:pokedex/meuPok.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex/data/servicoPoke.dart' as servicPoke;

class Time extends StatefulWidget {
  final List<int>? pokemons; // Lista de IDs dos Pokémons sem ser obrigatoria, pois o time pode ser vazio

  Time({
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
    _currentPokemons = widget.pokemons ?? []; // Use a lista passada ou inicialize como vazia
    if (_currentPokemons.isEmpty) {
      _loadCapturedPokemons(); // Carrega do SharedPreferences se a lista estiver vazia
    }// os pokemons que temos agr
    pokemonMapFuture = Pokemon.loadPokemonMap(); // Carregar o mapa de Pokémons
  }

//carrega a sharedpreferences para não perdemos o time
  Future<void> _loadCapturedPokemons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPokemons = prefs.getStringList('capturedPokemons')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }
//reseta os pokemons que temos
  void resetPokemons() {
    setState(() {
      _currentPokemons.clear(); // Limpa a lista de Pokémons
      // Se você quiser adicionar lógica para adicionar novos Pokémons, faça aqui
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
                  child: FutureBuilder<Map<int, Pokemon>>(
                    future: pokemonMapFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print('Erro ao carregar os Pokémons: ${snapshot.error}');
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      } else {
                        final pokemonMap = snapshot.data!;
                        print('Pokemon Map: $pokemonMap');

                        return ListView.builder(
                          itemCount: _currentPokemons.length > 6 ? 6 : _currentPokemons.length,
                          itemBuilder: (context, index) {
                            final pokemonId = _currentPokemons[index];
                            final pokemon = pokemonMap[pokemonId]; // Obtém o Pokémon pelo ID no Map

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
                                  //o time 'final' no momento que clicamos em um dos membros do time para caso solte o pokemon ele saiba
                                  //diminuir do numero e atualizar a lista
                                  final currentTeam = 
                                  _currentPokemons.map((id) => pokemonMap[id]).where((poke) => 
                                  poke != null).cast<Pokemon>().toList();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeuPok(
                                        pokemonName: pokemon.name, 
                                        pokemonId: pokemonId,
                                        team: currentTeam,//lista a remover
                                        onRelease: (id) {//função de remover
                                        setState(() {
                                          // Remova o Pokémon do time com base no ID
                                          _currentPokemons.removeWhere((pokeId) => pokeId == id);
                                        });
                                        }
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: const Color.fromARGB(255, 147, 146, 240),
                                  margin: EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    leading: pokemon.imageUrl.isNotEmpty 
                                        ? CachedNetworkImage(
                                            imageUrl: servicPoke.PokemonService.getPokemonImageUrl(pokemonId),
                                            placeholder: (context, url) => const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                            fit: BoxFit.cover,
                                          )
                                        : SizedBox(width: 50, height: 50, child: Icon(Icons.image_not_supported)),
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
}
