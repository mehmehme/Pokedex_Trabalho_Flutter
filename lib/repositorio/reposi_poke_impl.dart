import 'package:pokedex/data/data.dart';
import 'package:pokedex/repositorio/ApiClient.dart';
import 'package:pokedex/repositorio/reposi_poke.dart';

import '../dao/dao_mapper.dart';
import '../dao/pokemon_dao.dart';
import '../network/net_poke.dart';
import '../data/modelo_data.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonNetwork networkMapper;
  final PokemonDao pokemonDao;
  final PokeMapa databaseMapper;
  final ApiClient apiClient;

  PokemonRepositoryImpl({
    required this.apiClient,
    required this.pokemonDao,
    required this.databaseMapper,
    required this.networkMapper,
  });

  @override
  Future<Map<int, Pokemon>> getPokemons() async {
    // Tentar carregar a partir do banco de dados
    final dbPokemons = await pokemonDao.getAllCachedPokemons();
    
    // Se o dado já existe, carregar esse dado
    if (dbPokemons.isNotEmpty) {
      return dbPokemons;
    }

    // Caso contrário, buscar pela API remota
    final networkEntity = await apiClient.fetchPokemonList();
    
    // Salvar os dados no banco local para cache
    for (var pokemon in networkEntity.values) {
      await pokemonDao.insertPokemon(pokemon);
    }

    return networkEntity;
  }
}