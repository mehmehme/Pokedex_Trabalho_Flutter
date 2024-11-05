import 'package:flutter/material.dart';
import 'package:pokedex/dao/pokemon_dao.dart';
import 'package:pokedex/estilos/botoes.dart';
import 'package:provider/provider.dart';
import 'pokedex.dart';
import 'timePok.dart';
import 'captura.dart';
import 'estilos/fundoPoke.dart';
import '../repositorio/reposi_poke.dart';
import '../network/net_poke.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PokemonDao>(
          create: (_) => PokemonDao(),
        ),
        Provider<PokemonNetwork>(
          create: (_) => PokemonNetwork(),
        ),
        Provider<PokemonRepository>(
          create: (context) => PokemonRepository(
            pokemonDao: Provider.of<PokemonDao>(context, listen: false),
            pokemonNetwork: Provider.of<PokemonNetwork>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
      routes: {
        'tela1': (context) => const Pokedex(),
        'tela2': (context) => Captura(),
        'tela3': (context) => Time(), // Inicialmente vazia, pode ser atualizada
      },
    ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<int> capturedPokemons = [];

  void _onPokemonCaptured(int pokemonId) {
    setState(() {
      capturedPokemons.add(pokemonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          fundopoke(),
          Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 100.0,
                ),
                Stack(
                  children: [
                    Text(
                      "Pokedex",
                      style: TextStyle(
                        fontFamily: 'Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 80.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 15
                          ..color = const Color.fromARGB(255, 221, 155, 14),
                      ),
                    ),
                    const Text(
                      "Pokedex",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 248, 248),
                        fontFamily: 'Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 80.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 80.0,
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    botao(
                      buttonText: "Pokedex",
                      onPressed: () {
                        Navigator.pushNamed(context, 'tela1');
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    botao(
                      buttonText: "Capturar",
                      onPressed: () {
                        Navigator.pushNamed(context, 'tela2');
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    botao(
                      buttonText: "Meu Time",
                      onPressed: () {
                        Navigator.pushNamed(context, 'tela3');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
