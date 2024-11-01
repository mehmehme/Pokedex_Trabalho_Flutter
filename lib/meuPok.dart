import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/data/servicoPoke.dart' as servicPoke;

class MeuPok extends StatelessWidget{
final String pokemonName;
  final int pokemonId;
  final List<Pokemon> team; // Lista de Pokémons do time
  final Function(int) onRelease; // Função para liberar Pokémon

  const MeuPok({
    super.key,
    required this.pokemonName,
    required this.pokemonId,
    required this.team,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          pokemonName,
          style: TextStyle(
            color: Colors.white, // Define o texto do título em branco
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
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
        children: [
          Image.asset(
            'assets/images/fundo2.png',
            fit: BoxFit.cover, // Para cobrir toda a tela
            width: double.infinity,
            height: double.infinity,
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
                      const SizedBox(height: 18),
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
                                fontSize: 15,
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
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  //a barra de progresso pelo numero do dado
                                  LinearProgressIndicator(
                                    value: pokemon.base[key] / 100, // Supondo que o máximo é 100
                                    backgroundColor: Colors.white54,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      fixedSize: Size(MediaQuery.of(context).size.width*0.6, MediaQuery.of(context).size.height*0.1),
                                      backgroundColor: const Color.fromARGB(255, 167, 57, 57), // Cor do fundo
                                      side: const BorderSide(color: Color.fromARGB(255, 223, 121, 121), width: 6), // Cor e largura da borda
                                    ),
                                    onPressed: () {
                                      //retira o pokemon da lista
                                      onRelease(pokemonId);
                                      //volta ao time
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        //mostra uma mensagem
                                        const SnackBar(
                                          content: Text('Pokémon liberado!'),
                                          duration: Duration(seconds: 6),
                                        ),
                                      );},
                                    child: Text(
                                      'Soltar',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 255, 248, 248),
                                        fontFamily: 'Sans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.0,
                                    ),
                                    ),
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