class Pokemon {
  final int id;
  final String englishName;
  final String japaneseName;
  final String chineseName;
  final String frenchName;
  late final String? imgUrl;
  final List<String> type;
  final Map<String, int> base;

  Pokemon({
    required this.id,
    required this.englishName,
    required this.japaneseName,
    required this.chineseName,
    required this.frenchName,
    this.imgUrl,
    required this.type,
    required this.base,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      englishName: json['name']['english'],
      japaneseName: json['name']['japanese'],
      chineseName: json['name']['chinese'],
      frenchName: json['name']['french'],
      type: List<String>.from(json['type']),
      base: Map<String, int>.from(json['base'].map((key, value) => MapEntry(key, value as int))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {
        'english': englishName,
        'japanese': japaneseName,
        'chinese': chineseName,
        'french': frenchName,
      },
      'img': imgUrl,
      'type': type,
      'base': base,
    };
  }
}