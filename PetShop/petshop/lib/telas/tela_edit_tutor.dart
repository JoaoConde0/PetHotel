import 'package:flutter/material.dart';
import 'dart:convert'; // Necessário para codificar/decodificar JSON
import 'package:http/http.dart' as http;

class TelaEditarTutor extends StatefulWidget {
  final Map<String, dynamic> tutor;
  const TelaEditarTutor({super.key, required this.tutor});
  @override
  State<TelaEditarTutor> createState() => _TelaEditarTutorState();
}
class _TelaEditarTutorState extends State<TelaEditarTutor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _contatoController;
  late String _sexoSelecionado;
  late String? _metodoPagamentoSelecionado;
  bool _isLoading = false;
  final List<String> _metodosPagamento = ['Dinheiro', 'Pix', 'Crédito', 'Débito'];
  final String _baseUrl = 'http://000.000.000:3333';  //SEMPRE MUDAR

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.tutor['nomeTutor']);
    _contatoController = TextEditingController(text: widget.tutor['contatoTutor']);
    _sexoSelecionado = widget.tutor['sexoTutor'];
    _metodoPagamentoSelecionado = widget.tutor['pagamentoTutor'];
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/tutors/${widget.tutor['tutorId']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nome': _nomeController.text.trim(), 'contato': _contatoController.text.trim(), 'sexo': _sexoSelecionado, 'metodoPagamento': _metodoPagamentoSelecionado}),
      );
      if (mounted && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor atualizado com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else if(mounted) {
        throw Exception('Falha ao atualizar tutor.');
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _excluirTutor() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/tutors/${widget.tutor['tutorId']}'));
      if (mounted && response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor e pets associados excluídos!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else if (mounted) {
        throw Exception('Falha ao excluir tutor.');
      }
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoConfirmacao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este tutor? Esta ação não pode ser desfeita e excluirá todos os pets associados.'),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _excluirTutor();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _contatoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tutor'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _isLoading ? null : _salvarAlteracoes),
          IconButton(icon: const Icon(Icons.delete), onPressed: _isLoading ? null : _mostrarDialogoConfirmacao),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), validator: (v) => v == null || v.trim().isEmpty ? 'Por favor, insira o nome.' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _contatoController, decoration: const InputDecoration(labelText: 'Contato (Telefone)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone, validator: (v) => v == null || v.trim().isEmpty ? 'Por favor, insira o contato.' : null),
                  const SizedBox(height: 20),
                  const Text('Sexo:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RadioListTile<String>(title: const Text('Feminino'), value: 'Feminino', groupValue: _sexoSelecionado, onChanged: (v) => setState(() => _sexoSelecionado = v!)),
                  RadioListTile<String>(title: const Text('Masculino'), value: 'Masculino', groupValue: _sexoSelecionado, onChanged: (v) => setState(() => _sexoSelecionado = v!)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _metodoPagamentoSelecionado,
                    decoration: const InputDecoration(labelText: 'Método de Pagamento', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payment)),
                    items: _metodosPagamento.map((m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setState(() => _metodoPagamentoSelecionado = v),
                    validator: (v) => v == null ? 'Por favor, selecione um método.' : null,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}