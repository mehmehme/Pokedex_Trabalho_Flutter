
import '../data/modelo_data.dart';

class NetMapa {
  // Método para mapear um JSON para um objeto Pokemon
  static Pokemon fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int, // Assegura que o ID seja um inteiro
      name: json['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from(json['type'] ?? []),
      base: json['base'] ?? {},
    );
  }

  // Método para mapear uma lista de JSON para uma lista de objetos Pokemon
  static Map<int, Pokemon> fromJsonMap(List<dynamic> jsonList) {
  return {for (var json in jsonList) json['id'] as int: fromJson(json)};
  }
}
