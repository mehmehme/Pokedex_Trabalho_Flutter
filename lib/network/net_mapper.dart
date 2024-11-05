import '../data/modelo_data.dart';

class NetMapa {
  // Método para mapear um JSON para um objeto Pokemon
  static Pokemon fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: int.parse(json['id'].toString()), // Assegura que o ID seja um inteiro
      name: json['name']['english'] ?? 'Nome não disponível',
      type: List<String>.from(json['type'] ?? []),
      img: null, // Pode ser ajustado conforme necessário
      base: json['base'] ?? {},
    );
  }

  // Método para mapear uma lista de JSON para uma lista de objetos Pokemon
  static List<Pokemon> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}
