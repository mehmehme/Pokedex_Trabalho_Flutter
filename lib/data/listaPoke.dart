import 'package:flutter/material.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/data/servicoPoke.dart'; // Importa o serviço atualizado
import 'package:pokedex/desc.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  Map<int, Pokemon> pokemons = {};
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
      var result = await PokemonService.loadInitialPokemons();
      setState(() {
        pokemons = result.pokemons;
        hasMore = result.hasMore;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar Pokémon: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Carrega e adiciona se há mais Pokémons
  Future<void> _loadMorePokemons() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      var result = await PokemonService.loadMorePokemons(pokemons);
      setState(() {
        pokemons.addAll(result.pokemons); // Adiciona os novos Pokémons à lista
        hasMore = result.hasMore;
      });
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
        child: isLoading && pokemons.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: pokemons.length + (hasMore ? 1 : 0), // Adiciona um item para o carregamento
                itemBuilder: (context, index) {
                  if (index == pokemons.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final pokemon = pokemons.values.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Descricao(
                            pokemon: pokemon, 
                            pokemonName: pokemon.name, 
                            pokemonId: pokemon.id,),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(pokemon.name),
                        leading: Image.network(PokemonService.getPokemonImageUrl(pokemon.id)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
