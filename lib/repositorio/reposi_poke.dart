import 'package:pokedex/data/data.dart';

import '../data/modelo_data.dart';

abstract class PokemonRepository {

  Future<Map<int, Pokemon>> getPokemons();
}