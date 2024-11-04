import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/data/servicoPoke.dart' as pokemonServ;
import 'package:pokedex/desc.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  Map<int, Pokemon> pokemons = {}; // Altera para Map<int, Pokemon>
  int currentOffset = 0;
  bool isLoading = false;
  bool hasMore = true;
  late Future<Map<int, Pokemon>> futurePokemonMap;

  @override
  void initState() {
    super.initState();
    futurePokemonMap = Pokemon.loadPokemonMap();
    _loadInitialPokemons();
  }

  Future<void> _loadInitialPokemons() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool isConnected = await _checkInternetConnection();
      if (isConnected) {
        // Carregar da API
        List<Pokemon> allPokemons = (await pokemonServ.PokemonService.fetchAllPokemons()).cast<Pokemon>();
        await _cachePokemonData(allPokemons);
        setState(() {
          pokemons = {for (var pokemon in allPokemons) pokemon.id: pokemon}; // Mapeia os Pokémons
          currentOffset = pokemonServ.PokemonService.limit;
          hasMore = currentOffset < allPokemons.length;
        });
      } else {
        // Carregar do cache
        Map<int, Pokemon> cachedPokemons = await _loadPokemonsFromCache();
        setState(() {
          pokemons = cachedPokemons;
          hasMore = false; // Considera que o cache é o conjunto completo de dados offline
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar Pokémon: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Verifica se há conexão com a internet
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Carrega os Pokémon do cache
  Future<Map<int, Pokemon>> _loadPokemonsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedPokemonsJson = prefs.getStringList('cachedPokemons');
    Map<int, Pokemon> pokemons = {};

    if (cachedPokemonsJson != null) {
      for (var pokemonJson in cachedPokemonsJson) {
        try {
          // Tente decodificar e criar um Pokémon
          var decodedJson = jsonDecode(pokemonJson);
          Pokemon pokemon = Pokemon.fromMap(decodedJson); // Usando fromMap
          pokemons[pokemon.id] = pokemon; // Mapeia o Pokémon pelo ID
        } catch (e) {
          print('Erro ao carregar Pokémon do cache: $e');
        }
      }
    }
    return pokemons;
  }

  // Salva os dados dos Pokémon no cache
  Future<void> _cachePokemonData(List<Pokemon> pokemonList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> pokemonJsonList = pokemonList.map((pokemon) => jsonEncode(pokemon.toJson())).toList();
    await prefs.setStringList('cachedPokemons', pokemonJsonList);
  }

  // Carrega e adiciona se há mais Pokémons
  Future<void> _loadMorePokemons() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Aqui você deve usar o Map já carregado ao invés de buscar tudo novamente
      if (currentOffset < pokemons.length) {
        List<int> keys = pokemons.keys.toList();
        int nextOffset = currentOffset + pokemonServ.PokemonService.limit;
        if (nextOffset > keys.length) {
          nextOffset = keys.length; // Impede que saia do limite
        }
        // Atualiza os Pokémons visíveis
        setState(() {
          pokemons = {
            for (var id in keys.sublist(currentOffset, nextOffset)) id: pokemons[id]!
          };
          currentOffset = nextOffset;
          hasMore = currentOffset < keys.length;
        });
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar mais Pokémon: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
        title: const Text(
          'Pokédex',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading && hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMorePokemons();
          }
          return true;
        },
        child: ListView.builder(
          itemCount: pokemons.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == pokemons.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final pokemon = pokemons.values.elementAt(index); // Pega o Pokémon correspondente
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 77, 70, 141),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromARGB(255, 39, 53, 100), width: 4),
              ),
              child: GestureDetector(
                onTap: () {
                  // Vai para a descrição do Pokémon
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Descricao(
                        pokemonName: pokemon.name,
                        pokemonId: pokemon.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: const Color.fromARGB(255, 147, 146, 240),
                  child: ListTile(
                    leading: Image.network(pokemonServ.PokemonService.getPokemonImageUrl(pokemon.id)),
                    title: Text(
                      pokemon.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Tipo: ${pokemon.type.join(', ')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
