import 'package:flutter/material.dart';
import 'package:pokedex/data/providersTree.dart';
import 'package:pokedex/estilos/botoes.dart';
import 'package:provider/provider.dart';
import 'telas/pokedex.dart';
import 'telas/captura.dart';
import 'estilos/fundoPoke.dart';
import '../telas/timePok.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final data = await ConfigureProviders.createDependencyTree();
  runApp(MainApp(data: data));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.data});
  final ConfigureProviders data;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: data.providers,
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
