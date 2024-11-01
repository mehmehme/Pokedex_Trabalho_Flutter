import 'package:flutter/material.dart';
import 'package:pokedex/data/listaPoke.dart';
import 'package:pokedex/estilos/fundoPokedex.dart';


class Pokedex extends StatefulWidget {
  const Pokedex({super.key});

  @override
  State<Pokedex> createState() => _PokedexState();
}

class _PokedexState extends State<Pokedex> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children:[
        fundoGradiente(),
        PokemonListScreen(),
      ],
      ),
    );
  }
}