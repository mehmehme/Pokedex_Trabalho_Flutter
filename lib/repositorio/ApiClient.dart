import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/data/data.dart';
import 'package:pokedex/data/modelo_data.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl}) {
    _dio = Dio()
      ..options.baseUrl = baseUrl
      ..interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
  }

  Future<Map<int, Pokemon>> fetchPokemonList() async {
    try {
      final response = await _dio.get("/pokemon");

      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Center(child: Text(
          "Oh nooo",
        ),);
      }

      final List<dynamic> data = response.data;
      Map<int, Pokemon> pokemons = {
        for (var json in data) json['id'] as int: Pokemon.fromJson(json),
      };

      return pokemons;

    } catch (e) {
      throw Text('Failed to fetch Pokémons');
    }
  }
}
