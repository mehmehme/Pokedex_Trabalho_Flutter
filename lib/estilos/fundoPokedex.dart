import 'package:flutter/material.dart';

class fundoGradiente extends StatelessWidget {
  const fundoGradiente({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 136, 177, 211), // Tom mais claro
            Color.fromARGB(255, 71, 99, 131), // Tom mais escuro
          ],
        ),
      ),
    );
  }
}