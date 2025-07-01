import 'package:flutter/material.dart';
//import de paginas

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define uma cor de fundo para a tela
      backgroundColor: Colors.indigo[50],
      body: Center(
        // Centraliza todo o conteúdo na tela
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Alinha os itens no centro verticalmente
            children: <Widget>[
              // Ícone para representar o app
              const Icon(
                Icons.pets,
                size: 100,
                color: Colors.indigo,
              ),
              const SizedBox(height: 20), // Espaçamento
              // Título do aplicativo
              const Text(
                'Pet Hotel Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10), // Espaçamento
              // Subtítulo ou slogan
              Text(
                'A casa longe de casa para o seu melhor amigo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 60), // Espaçamento maior antes do botão
              // Botão para iniciar
              ElevatedButton(
                onPressed: () {
                  // Navega para a Tela Principal, permitindo que o usuário
                  // retorne para a tela de início.
                  Navigator.pushNamed(context, '/principal');
                },
                child: const Text('Iniciar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}