import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:pokedex/data/modelo_data.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/telas/desc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Tenta carregar os dados da internet
      var response = await http.get(Uri.parse("http://192.168.0.23:3000/pokemon"));
      
      if (response.statusCode == 200) {
        // Se os dados forem carregados com sucesso da API
        var fetchedPokemons = jsonDecode(response.body);
        _cachePokemons(fetchedPokemons); // Armazena em cache
        _updatePokemons(fetchedPokemons);
      } else {
        // Se falhar, tenta carregar do cache
        var cachedPokemons = await _getCachedPokemons();
        if (cachedPokemons != null) {
          _updatePokemons(cachedPokemons);
        } else {
          _showError("Erro ao carregar Pokémons");
        }
      }
    } catch (e) {
      var cachedPokemons = await _getCachedPokemons();
      if (cachedPokemons != null) {
        _updatePokemons(cachedPokemons);
      } else {
        _showError("Erro ao carregar Pokémons");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Função para atualizar os dados da UI
  void _updatePokemons(List<dynamic> fetchedPokemons) {
    if(mounted){
      setState(() {
        pokemons = { for (var p in fetchedPokemons) p['id']: Pokemon.fromJson(p) };
        hasMore = fetchedPokemons.isNotEmpty;
      });
    }
  }

  // Função para armazenar os Pokémons em cache
  Future<void> _cachePokemons(List<dynamic> pokemons) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedPokemons', jsonEncode(pokemons));
  }

  // Função para recuperar os Pokémons do cache
  Future<List<dynamic>?> _getCachedPokemons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cachedPokemons');
    if (cachedData != null) {
      return jsonDecode(cachedData);
    }
    return null;
  }

  // Função para exibir erros
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 36, 39, 59),
        centerTitle: true,
        title: const Text('Pokédex', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading && pokemons.isEmpty
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
                            imageUrl: pokemon?.imgUrl ?? '',
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            pokemon!.englishName,
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
      );
  }
}
