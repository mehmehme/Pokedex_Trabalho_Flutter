import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pokedex/repositorio/reposi_poke_impl.dart';
import 'package:pokedex/telas/desc.dart';
import 'package:provider/provider.dart';

import '../../data/modelo_data.dart';

class ListaPoke extends StatefulWidget {
  const ListaPoke({super.key});

  @override
  _ListaPokeState createState() => _ListaPokeState();
}

class _ListaPokeState extends State<ListaPoke> {
  Map<int,Pokemon> pokemons = {};
  bool isLoading = false;
  bool hasMore = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPokemons();
  }

  Future<void> _loadPokemons() async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedPokemons = await context.read<PokemonRepositoryImpl>().getPokemons();
      if (mounted) { // Verifica se o widget está montado
        setState(() {
          pokemons = fetchedPokemons;
          hasMore = fetchedPokemons.isNotEmpty;
        });
      } 
    } catch (e) {
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar os Pokémons: $e")),
        );
      });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
              colors: [Color.fromARGB(255, 65, 50, 78), Color.fromARGB(255, 65, 50, 78)],
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
            _loadPokemons();
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

                  final pokemon = pokemons[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 77, 70, 141),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color.fromARGB(255, 39, 53, 100), width: 4),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        Pokemon? fullPokemon = pokemon;
                        
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
                            imageUrl: context.read<PokemonRepositoryImpl>().networkMapper.getPokemonImageUrl(pokemon!.id),
                            placeholder: (context, url) => const CircularProgressIndicator(),
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
