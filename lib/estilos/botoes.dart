import 'package:flutter/material.dart';

class botao extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const botao({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
          fixedSize: Size(MediaQuery.of(context).size.width*0.6, MediaQuery.of(context).size.height*0.1),
          backgroundColor: const Color.fromARGB(255, 230, 170, 60), // Cor do fundo
          side: const BorderSide(color: const Color.fromARGB(255, 180, 85, 8), width: 8) // Cor e largura da borda
        ),
        onPressed:onPressed, 
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Color.fromARGB(255, 102, 52, 23),
            fontFamily: 'Sans',
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
         ),
        ),
       );
  }
}