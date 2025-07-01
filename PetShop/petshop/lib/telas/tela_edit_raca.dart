import 'package:flutter/material.dart';
import 'dart:convert'; // Necessário para codificar/decodificar JSON
import 'package:http/http.dart' as http;


class TelaEditarRaca extends StatefulWidget {
  final Map<String, dynamic> raca;
  const TelaEditarRaca({super.key, required this.raca});
  @override
  State<TelaEditarRaca> createState() => _TelaEditarRacaState();
}
class _TelaEditarRacaState extends State<TelaEditarRaca> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late String _especieSelecionada;
  bool _isLoading = false;
  final String _baseUrl = 'http://150.164.247.209:3333';  //SEMPRE MUDAR

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.raca['nomeRaca']);
    _especieSelecionada = widget.raca['especie'];
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/racas/${widget.raca['racaId']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nome': _nomeController.text.trim()}),
      );
      if (mounted && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Raça atualizada com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else if (mounted) {
        throw Exception('Falha ao atualizar a raça.');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirRaca() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/racas/${widget.raca['racaId']}'));
      if (mounted && response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Raça excluída com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else if (mounted) {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Falha ao excluir a raça.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoConfirmacao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta raça? Esta ação não pode ser desfeita e pode falhar se houver pets associados a ela.'),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _excluirRaca();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Raça'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _isLoading ? null : _salvarAlteracoes),
          IconButton(icon: const Icon(Icons.delete), onPressed: _isLoading ? null : _mostrarDialogoConfirmacao),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Espécie não pode ser alterada.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  RadioListTile<String>(title: const Text('Cachorro'), value: 'Cachorro', groupValue: _especieSelecionada, onChanged: null),
                  RadioListTile<String>(title: const Text('Gato'), value: 'Gato', groupValue: _especieSelecionada, onChanged: null),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome da Raça', border: OutlineInputBorder(), prefixIcon: Icon(Icons.pets)),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Por favor, insira o nome da raça.' : null,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}