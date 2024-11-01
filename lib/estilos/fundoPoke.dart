import 'package:flutter/material.dart';

class fundopoke extends StatelessWidget {
  const fundopoke({super.key});

  @override
  Widget build(BuildContext context) {
    double circleHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      body: Stack(
      children: [
        Image.asset('assets/images/fundo.jpg',
            fit: BoxFit.cover, // Para cobrir toda a tela
            width: double.infinity,
            height: double.infinity,
          ),
        // Círculo superior (metade vermelha da Pokébola)
        Align(
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0, -circleHeight / 8), // Subindo a metade inferior
            child: Container(
            width:circleHeight,
            height: circleHeight/4,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 167, 57, 57),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(circleHeight/2.3),
                ),
              ),
            ),
          ),
        ),

        //linha preta
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 20,
            color: Colors.black,
          ),
        ),

        //bola branca do centro
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 8),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),

        // Círculo inferior (metade branca da Pokébola)
        Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, -circleHeight / 4.2), // Subindo a metade inferior
            child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(circleHeight/2),
              ),
            ),
          ),
        ),
        ),
      ],
    ),
    );
  }
}