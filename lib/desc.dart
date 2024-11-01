import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/data/servicoPoke.dart' as servicPoke;
import 'package:pokedex/data/data.dart';

//cria a descrição
class Descricao extends StatelessWidget {
  final String pokemonName;
  final int pokemonId;

  const Descricao({
    super.key,
    required this.pokemonName,
    required this.pokemonId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      //pega os detalhes do pokemon
      body: FutureBuilder<Pokemon>(
        future: servicPoke.PokemonService.fetchPokemonDetails(pokemonName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else {
            final pokemon = snapshot.data!;
            return Stack(
              //fundo
              children: [
                Image.asset(
                  'assets/images/fundo2.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error); // O que fazer se a imagem falhar ao carregar
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 80.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 119, 10, 38),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            width: 8,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: servicPoke.PokemonService.getPokemonImageUrl(pokemonId),
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 250,
                        height: 450,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 119, 10, 38),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            width: 8,
                          ),
                        ),
                        //nome do pokemon
                        child: Column(
                          children: [
                            Text(
                              pokemon.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            //tipo do pokemon
                            Text(
                              'Tipo: ${pokemon.type.join(', ')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              'Informações Básicas',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //cada informação do pokemon divida
                            const Divider(),
                             // vai para cada atributo
                            for (var key in pokemon.base.keys)
                            //coluna dos tipos
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //o tipo
                                  Text(
                                    '$key: ${pokemon.base[key]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  //a barra de progresso pelo numero do dado
                                  LinearProgressIndicator(
                                    value: pokemon.base[key] / 100, // Supondo que o máximo é 100
                                    backgroundColor: Colors.white54,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
