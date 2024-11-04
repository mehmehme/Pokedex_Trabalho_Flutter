import 'package:flutter/material.dart';
import 'package:pokedex/desc.dart';
import 'package:pokedex/estilos/botoes.dart';
import 'pokedex.dart';
import 'timePok.dart';
import 'captura.dart';
import 'estilos/fundoPoke.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
      routes: {
        'tela1': (context) => const Pokedex(),
        'tela2': (context) => Captura(),
        'tela3': (context) => Time(), // Inicialmente vazia, pode ser atualizada
        'tela4': (context) => const Descricao(pokemonName: '', pokemonId: 0, pokemon: 0,),
      },
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
                          ..color = const Color.fromARGB(255, 99, 22, 22),
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
