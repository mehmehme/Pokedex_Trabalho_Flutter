import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/data/servicoPoke.dart';
import 'package:pokedex/desc.dart';

class ListaPoke extends StatefulWidget {
  const ListaPoke({super.key});

  @override
  _ListaPokeState createState() => _ListaPokeState();
}

class _ListaPokeState extends State<ListaPoke> {
  Map<int, Pokemon> pokemons = {};
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitialPokemons();
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _loadInitialPokemons() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (await hasInternetConnection()) {
        // Carrega os Pokémons da API e salva no cache
        var result = await PokemonService.loadInitialPokemons();
        setState(() {
          pokemons = result.pokemons;
          hasMore = result.hasMore;
        });
      } else {
        // Carrega os Pokémons do cache
        var cachedPokemons = await PokemonService.loadCachedPokemons();
        setState(() {
          pokemons = cachedPokemons;
          hasMore = cachedPokemons.isNotEmpty;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar Pokémon: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar mais Pokémon: $e')),
      );
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
                itemCount: pokemons.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == pokemons.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final pokemon = pokemons.values.elementAt(index);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 77, 70, 141),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color.fromARGB(255, 39, 53, 100), width: 4),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        Pokemon fullPokemon = pokemon;
                        if (!await hasInternetConnection()) {
                          fullPokemon = await PokemonService.fetchPokemonDetails(pokemon.name); // Carrega detalhes do cache
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Descricao(pokemon: fullPokemon),
                          ),
                        );
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 147, 146, 240),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: PokemonService.getPokemonImageUrl(pokemon.id),
                            placeholder: (context, url) => const CircularProgressIndicator(),
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
                            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
