import '../dao/pokemon_dao.dart';
import '../network/net_poke.dart';
import '../data/modelo_data.dart';

class PokemonRepository {
  final PokemonDao pokemonDao;
  final PokemonNetwork pokemonNetwork;

  PokemonRepository({
    required this.pokemonDao,
    required this.pokemonNetwork,
  });

  Future<List<Pokemon>> getPokemons() async {
    // Tenta obter os Pokémons do cache
    List<Pokemon> cachedPokemons = await pokemonDao.getAllCachedPokemons();
    
    if (cachedPokemons.isNotEmpty) {
      return cachedPokemons;
    }

    // Se o cache estiver vazio, busca da internet e armazena no cache
    List<Pokemon> fetchedPokemons = await pokemonNetwork.fetchPokemonList();
    for (var pokemon in fetchedPokemons) {
      // Mapeia o Pokémon para um Map e insere no banco de dados
      await pokemonDao.insertPokemon(pokemon);
    }

    return fetchedPokemons;
  }
}
