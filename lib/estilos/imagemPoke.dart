import 'dart:typed_data';
import 'package:flutter/material.dart';

class PokemonImage extends StatelessWidget {
  final Uint8List? imgBytes;

  const PokemonImage({Key? key, required this.imgBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return imgBytes != null
        ? Image.memory(imgBytes!) // Mostra a imagem em cache
        : Icon(Icons.image_not_supported, size: 50, color: Colors.grey); // Mostra o ícone quando a imagem não está disponível
  }
}
