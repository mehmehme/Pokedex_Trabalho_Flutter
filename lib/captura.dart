import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pokedex/estilos/botoes.dart';
import 'package:pokedex/timePok.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Captura extends StatefulWidget {
  @override
  State<Captura> createState() => _CapturaState();
}

class _CapturaState extends State<Captura> {
  int? _pokemonId;
  String _pokemonName = '';
  DateTime? _lastSelectedDate;
  DateTime? _lastCapturedDate;
  List<int> _capturedPokemons = []; // Lista de Pokémons capturados

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carrega os Pokémon capturados e as datas
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSelectedDate = DateTime.tryParse(prefs.getString('lastSelectedDate') ?? '');
      _lastCapturedDate = DateTime.tryParse(prefs.getString('lastCapturedDate') ?? '');
      _capturedPokemons = prefs.getStringList('capturedPokemons')?.map((e) => int.parse(e)).toList() ?? [];
      _pokemonId = prefs.getInt('pokemonId');
      _pokemonName = prefs.getString('pokemonName') ?? '';
    });
  }

  // Salva o Pokémon escolhido e as datas
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSelectedDate', DateTime.now().toIso8601String());
    await prefs.setString('lastCapturedDate', DateTime.now().toIso8601String());
    await prefs.setStringList('capturedPokemons', _capturedPokemons.map((e) => e.toString()).toList());
    if (_pokemonId != null) {
      await prefs.setInt('pokemonId', _pokemonId!);
      await prefs.setString('pokemonName', _pokemonName);
    }
  }

  // Escolhe um Pokémon de forma aleatória
  void _randomizePokemon() {
    final random = Random();
    int newPokemonId = random.nextInt(809); // São 809 Pokémon (1-809)
    String newPokemonName = "Pokémon #$newPokemonId";
    setState(() {
      _pokemonId = newPokemonId;
      _pokemonName = newPokemonName;
    });
    _saveData(); // Salva o Pokémon escolhido
  }

  // Função para passar o dia e checar se há um novo Pokémon
  void _onPassDay() {
    final now = DateTime.now();
    if (_lastSelectedDate == null || now.year != _lastSelectedDate!.year || now.day != _lastSelectedDate!.day) {
      _randomizePokemon();
    } else {
      // Se o Pokémon foi selecionado hoje, mostra uma mensagem
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Você já escolheu um Pokémon hoje.")));
    }
  }

  // Função de captura dos Pokémon
  void _capturePokemon() {
    final now = DateTime.now();

    // Caso o time esteja cheio
    if (_capturedPokemons.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Você já capturou 6 Pokémon.")));
      return;
    }
    // Se já capturou o Pokémon no dia
    if (_lastCapturedDate != null && now.year == _lastCapturedDate!.year && now.day == _lastCapturedDate!.day) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Você já capturou um Pokémon hoje.")));
      return;
    }

    // Adiciona o Pokémon capturado à lista
    if (_pokemonId != null) { // Verifica se o Pokémon ID não é nulo
      setState(() {
        _capturedPokemons.add(_pokemonId!); // Adiciona o Pokémon à lista de capturados
        _lastCapturedDate = now; // Atualiza a data da última captura
      });
      _saveData(); // Salva os dados

      // Navega para a tela de Pokémon capturados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Time(pokemons: List.from(_capturedPokemons)), // Passa a lista de Pokémons capturados
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pokémon $_pokemonName capturado!")));
    }
  }

  // Função para resetar os Pokémons capturados caso o time fique cheio durante os testes
  void _resetCaptures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _capturedPokemons.clear(); // Limpa a lista de Pokémons capturados
      _lastCapturedDate = null; // Reseta a data de captura
    });
    await prefs.remove('capturedPokemons'); // Remove as capturas armazenadas
    await prefs.remove('lastCapturedDate'); // Remove a data da última captura
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pokémon capturados resetados!")));
  }

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
          'Quem é esse Pokemon?!',
          style: TextStyle(
            color: Colors.white, // Define o texto do título em branco
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetCaptures, // Chama o método de reset
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fundo2.png',
            fit: BoxFit.cover, // Para cobrir toda a tela
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pega imagem se não nulo
                if (_pokemonId != null) ...[
                  Image.network(
                    'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_pokemonId!.toString().padLeft(3, '0')}.png',
                    height: 150,
                    width: 150,
                  ),
                  // Pega o nome se não nulo
                  SizedBox(height: 10),
                  Text(
                    _pokemonName,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 129, 38, 38),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
                // Passa o dia
                SizedBox(height: 20),
                botao(
                  onPressed: _onPassDay,
                  buttonText: 'Passar Dia',
                ),
                SizedBox(height: 20),
                botao(
                  onPressed: _capturePokemon,
                  buttonText: 'Capturar',
                ),
                SizedBox(height: 20),
                // Quantos já foram capturados
                Text(
                  'Pokémons Capturados: ${_capturedPokemons.length}/6',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 129, 38, 38),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
