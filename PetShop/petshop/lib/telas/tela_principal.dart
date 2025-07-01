import 'package:flutter/material.dart';
import 'dart:convert'; // Necessário para codificar/decodificar JSON
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pacote para requisições HTTP
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//Tela detalhe
import 'tela_detalhes.dart';


class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMenuOpen = false;

  // Variáveis de estado para a lista de pets
  List<dynamic> _pets = [];
  bool _isLoading = true;
  final String _baseUrl = 'http://150.164.247.209:3333';  //SEMPRE MUDAR

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    )..addListener(() {
      setState(() {});
    });
    _fetchPets(); // Busca os pets ao iniciar a tela
  }

  Future<void> _fetchPets() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pets'));
      if (response.statusCode == 200) {
        setState(() {
          _pets = json.decode(response.body);
        });
      } else {
        throw Exception('Falha ao carregar pets');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar pets: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animais Hospedados'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pets.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum pet cadastrado ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _pets.length,
                    itemBuilder: (context, index) {
                      return _buildPetCard(_pets[index]);
                    },
                  ),
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMenuButton(icon: Icons.person_add, label: 'Novo Tutor', route: '/novo-tutor'),
          const SizedBox(height: 12),
          _buildMenuButton(icon: Icons.category, label: 'Nova Raça', route: '/nova-raca'),
          const SizedBox(height: 12),
          _buildMenuButton(icon: Icons.pets, label: 'Novo Pet', route: '/novo-pet'),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _toggleMenu,
            backgroundColor: Colors.indigoAccent,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isMenuOpen ? 0.13 : 0,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // MODIFICAÇÃO: Adicionado GestureDetector para tornar o card clicável
  Widget _buildPetCard(Map<String, dynamic> pet) {
    final bool isDog = pet['especie'] == 'Cachorro';
    final cardColor = isDog ? Colors.blue[100] : Colors.orange[100];
    final iconColor = isDog ? Colors.blue[800] : Colors.orange[800];
    final petIcon = isDog ? MdiIcons.dog : MdiIcons.cat;
    
    String dataEntradaFormatada = 'Data de entrada não informada';
    if (pet['dataEntrada'] != null) {
      try {
        dataEntradaFormatada = "Entrada: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(pet['dataEntrada']))}";
      } catch (e) {
        dataEntradaFormatada = "Data inválida";
      }
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaDetalhesPet(pet: pet),
          ),
        );
        // Recarrega a lista quando voltar da tela de detalhes
        _fetchPets();
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), border: Border(left: BorderSide(color: iconColor!, width: 8))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            leading: Icon(petIcon, color: iconColor, size: 40),
            title: Text(pet['nomeTutor'] ?? 'Tutor não encontrado', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text("${pet['especie'] ?? 'Espécie'} • ${pet['nomeRaca'] ?? 'Raça desconhecida'}\n$dataEntradaFormatada", style: TextStyle(fontSize: 14, color: Colors.grey[800])),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required String route}) {
    return ScaleTransition(
      scale: _animation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
            child: Text(label, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: label, // Usar uma tag única para cada FAB
            onPressed: () async {
              _toggleMenu();
              await Navigator.pushNamed(context, route);
              _fetchPets();
            },
            backgroundColor: Colors.indigo.shade100,
            child: Icon(icon, color: Colors.indigo),
          ),
        ],
      ),
    );
  }
}