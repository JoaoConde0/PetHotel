import 'package:flutter/material.dart';
//import de paginas
import 'telas/tela_inicio.dart';
import 'telas/tela_principal.dart';
import 'telas/tela_cad_tutor.dart';
import 'telas/tela_cad_raca.dart';
import 'telas/tela_cad_pet.dart';

//Importantes


void main() {
  runApp(const PetHotelApp());
}

class PetHotelApp extends StatelessWidget {
  const PetHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conds Hotel Pet',
      // Define um tema visual para o aplicativo
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define um estilo padrão para os botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false, // Remove o banner de "Debug"
      // Define a tela inicial do aplicativo
      initialRoute: '/',
      // Define as rotas de navegação do aplicativo
      routes: {
        '/': (context) => const TelaInicio(),
        '/principal': (context) => const TelaPrincipal(), // Rota para a tela principal
        '/novo-pet': (context) => const TelaCadastroPet(), // Rota para cadastro de Pet
        '/novo-tutor': (context) => const TelaCadastroTutor(), // Rota para cadastro de Tutor
        '/nova-raca': (context) => const TelaCadastroRaca(), // Rota para cadastro de Raça
      },
    );
  }
}