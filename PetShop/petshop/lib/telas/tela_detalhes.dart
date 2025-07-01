import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tela_edit_pet.dart';
import 'tela_edit_tutor.dart';
import 'tela_edit_raca.dart';

class TelaDetalhesPet extends StatefulWidget {
  final Map<String, dynamic> pet;

  const TelaDetalhesPet({super.key, required this.pet});
  @override
  State<TelaDetalhesPet> createState() => _TelaDetalhesPetState();
}
class _TelaDetalhesPetState extends State<TelaDetalhesPet> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
    if (_isMenuOpen) _animationController.forward();
    else _animationController.reverse();
  }

  String _calcularDiarias(String dataEntradaStr, String? dataSaidaStr) {
    try {
      final dataEntrada = DateTime.parse(dataEntradaStr);
      final hoje = DateTime.now();
      final diariasAteMomento = hoje.difference(dataEntrada).inDays;
      String textoDiariasAteMomento = diariasAteMomento >= 0 ? '$diariasAteMomento' : '0';
      String textoDiariasTotais = 'Não definida';
      if (dataSaidaStr != null) {
        final dataSaida = DateTime.parse(dataSaidaStr);
        final diariasTotais = dataSaida.difference(dataEntrada).inDays;
        textoDiariasTotais = diariasTotais >= 0 ? '$diariasTotais' : '0';
      }
      return 'Diárias até o momento: $textoDiariasAteMomento\nDiárias totais previstas: $textoDiariasTotais';
    } catch (e) {
      return 'Erro ao calcular diárias.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes de ${widget.pet['nomeRaca']}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informações do Pet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.indigo)),
                    const Divider(),
                    _buildInfoRow(Icons.pets, 'Espécie', widget.pet['especie'] ?? 'N/A'),
                    _buildInfoRow(Icons.category, 'Raça', widget.pet['nomeRaca'] ?? 'N/A'),
                    _buildInfoRow(Icons.calendar_today, 'Entrada', DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.pet['dataEntrada']))),
                    _buildInfoRow(Icons.calendar_today, 'Saída Prevista', widget.pet['dataSaida'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.pet['dataSaida'])) : 'Não definida'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.timer, 'Hospedagem', _calcularDiarias(widget.pet['dataEntrada'], widget.pet['dataSaida'])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informações do Tutor', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.indigo)),
                    const Divider(),
                    _buildInfoRow(Icons.person, 'Nome', widget.pet['nomeTutor'] ?? 'N/A'),
                    _buildInfoRow(Icons.phone, 'Contato', widget.pet['contatoTutor'] ?? 'N/A'),
                    _buildInfoRow(Icons.wc, 'Sexo', widget.pet['sexoTutor'] ?? 'N/A'),
                    _buildInfoRow(Icons.payment, 'Pagamento', widget.pet['pagamentoTutor'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildEditMenuButton(
            icon: Icons.pets_outlined, 
            label: 'Editar Pet',
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TelaEditarPet(pet: widget.pet)));
              if (result == true && mounted) {
                Navigator.pop(context, true); // Volta para a lista principal e sinaliza para atualizar
              }
            }
          ),
          const SizedBox(height: 12),
          _buildEditMenuButton(
            icon: Icons.person_outline, 
            label: 'Editar Tutor',
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TelaEditarTutor(tutor: widget.pet)));
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            }
          ),
          const SizedBox(height: 12),
          _buildEditMenuButton(
            icon: Icons.category_outlined, 
            label: 'Editar Raça',
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TelaEditarRaca(raca: widget.pet)));
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            }
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _toggleMenu,
            backgroundColor: Colors.indigoAccent,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo.shade300, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMenuButton({required IconData icon, required String label, required VoidCallback onPressed}) {
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
            heroTag: label,
            onPressed: onPressed,
            backgroundColor: Colors.indigo.shade100,
            child: Icon(icon, color: Colors.indigo),
          ),
        ],
      ),
    );
  }
}