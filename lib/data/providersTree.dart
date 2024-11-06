import 'package:pokedex/dao/dao_mapper.dart';
import 'package:pokedex/dao/pokemon_dao.dart';
import 'package:pokedex/network/net_poke.dart';
import 'package:pokedex/repositorio/ApiClient.dart';
import 'package:pokedex/repositorio/reposi_poke_impl.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {
    final apiClient = ApiClient(baseUrl: "http://192.168.0.23:3000");
    final networkMapper = PokemonNetwork();
    final databaseMapper = PokeMapa();
    final pokemonDao = PokemonDao();

    final pokemonRepository = PokemonRepositoryImpl(
      apiClient: apiClient,
      networkMapper: networkMapper,
      databaseMapper: databaseMapper,
      pokemonDao: pokemonDao,
    );

    return ConfigureProviders(providers: [
      Provider<ApiClient>.value(value: apiClient),
      Provider<PokemonNetwork>.value(value: networkMapper),
      Provider<PokeMapa>.value(value: databaseMapper),
      Provider<PokemonDao>.value(value: pokemonDao),
      Provider<PokemonRepositoryImpl>.value(value: pokemonRepository),
    ]);
  }
}
