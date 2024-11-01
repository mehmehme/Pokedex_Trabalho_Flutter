import 'package:flutter/material.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/data/servicoPoke.dart' as pokemonServ;
import 'package:pokedex/desc.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Pokemon> pokemons = []; // Altera para a lista de Pokémon
  int currentOffset = 0;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitialPokemons();
  }

  // Carrega os primeiros Pokémon e configura a paginação
  Future<void> _loadInitialPokemons() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Pokemon>? allPokemons = (await pokemonServ.PokemonService.fetchAllPokemons()).cast<Pokemon>();
      if (allPokemons.isNotEmpty) {
        setState(() {
          pokemons = allPokemons.sublist(0, pokemonServ.PokemonService.limit);
          currentOffset = pokemonServ.PokemonService.limit;
          hasMore = currentOffset < allPokemons.length;
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
  // Carrega mais Pokémon para paginação local
  Future<void> _loadMorePokemons() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });
//ve se precisa carregar mais
    try {
      List<dynamic> allPokemons = await pokemonServ.PokemonService.fetchAllPokemons();
      if (currentOffset < allPokemons.length) {
        int nextOffset = currentOffset + pokemonServ.PokemonService.limit;
        setState(() {
          pokemons.addAll(allPokemons.sublist(currentOffset, nextOffset) as Iterable<Pokemon>);
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
//cria a lista
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