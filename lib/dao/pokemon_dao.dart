import 'package:pokedex/data/data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/modelo_data.dart';

class PokemonDao {
  static const String tablePokemon = 'pokemons';
  static const String databaseName = 'pokemon_cache.db';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $tablePokemon(
            id INTEGER PRIMARY KEY,
            name TEXT,
            type TEXT,
            img BLOB,
            base TEXT
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertPokemon(Pokemon pokemon) async {
    final db = await database;
    await db.insert(
      tablePokemon,
      pokemon.toJson(),
      //pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<int, Pokemon>> getAllCachedPokemons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePokemon);

    return {
      for (var map in maps)
        map['id'] as int: Pokemon.fromJson(map)
    };
  }
}