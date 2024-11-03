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
  List<Pokemon> pokemons = []; //lista de pokemons
  int currentOffset = 0;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
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
          pokemons = allPokemons.sublist(0, pokemonServ.PokemonService.limit);
          currentOffset = pokemonServ.PokemonService.limit;
          hasMore = currentOffset < allPokemons.length;
        });
      } else {
        // Carregar do cache
        List<Pokemon> cachedPokemons = await _loadPokemonsFromCache();
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
  Future<List<Pokemon>> _loadPokemonsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedPokemonsJson = prefs.getStringList('cachedPokemons');
    List<Pokemon> pokemons = [];

  if (cachedPokemonsJson != null) {
      for (var pokemonJson in cachedPokemonsJson) {
        try {
          // Tente decodificar e criar um Pokémon
          var decodedJson = jsonDecode(pokemonJson);
          pokemons.add(Pokemon.fromJson(decodedJson));
        } catch (e) {
          // Se houver um erro, imprima ou trate conforme necessário
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
//carrega e adiciona se há mais pokemons
  Future<void> _loadMorePokemons() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
     List<Pokemon> allPokemons = (await pokemonServ.PokemonService.fetchAllPokemons()).cast<Pokemon>();
      if (currentOffset < allPokemons.length) {
        int nextOffset = currentOffset + pokemonServ.PokemonService.limit;
        setState(() {
          pokemons.addAll(allPokemons.sublist(currentOffset, nextOffset));
          currentOffset = nextOffset;
          hasMore = currentOffset < allPokemons.length;
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
              colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 177, 53, 53)], // Cores do gradiente
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Pokédex',
          style: TextStyle(
            color: Colors.white,  // Define o texto do título em branco
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        )
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
            final pokemon = pokemons[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Espaçamento entre os itens
              decoration: BoxDecoration(
              color: const Color.fromARGB(255, 77, 70, 141), // Cor de fundo do item
              borderRadius: BorderRadius.circular(12), // Arredonda as bordas
              border: Border.all(color: const Color.fromARGB(255, 39, 53, 100), width: 4), // Borda personalizada
            ),
              child: GestureDetector(
                onTap: () {
                  // Vai para a descrição do pokemon
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
                    //pega a imaem e nome do pokemon
                    leading: Image.network(pokemonServ.PokemonService.getPokemonImageUrl(pokemon.id)),
                    title: Text(pokemon.name,
                    style: const TextStyle(
                    color: Colors.white, // Cor do texto
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    ),
                    ),
                    subtitle: Text(
                      'Tipo: ${pokemon.type.join(', ')}', // Converte a lista de tipos em uma string
                      style: const TextStyle(
                        color: Colors.white, // Cor do texto
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