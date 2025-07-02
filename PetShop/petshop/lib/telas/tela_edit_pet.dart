import 'package:flutter/material.dart';
import 'dart:convert'; // Necessário para codificar/decodificar JSON
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pacote para requisições HTTP

class TelaEditarPet extends StatefulWidget {
  final Map<String, dynamic> pet;
  const TelaEditarPet({super.key, required this.pet});
  @override
  State<TelaEditarPet> createState() => _TelaEditarPetState();
}
class _TelaEditarPetState extends State<TelaEditarPet> {
  final _formKey = GlobalKey<FormState>();
  final String _baseUrl = 'http://000.000.000:3333';  //SEMPRE MUDAR
  bool _isLoading = true;
  int? _tutorSelecionadoId;
  int? _racaSelecionadaId;
  late String _especieSelecionada;
  DateTime? _dataEntrada;
  DateTime? _dataSaida;
  final _dataEntradaController = TextEditingController();
  final _dataSaidaController = TextEditingController();
  List<dynamic> _tutores = [];
  List<dynamic> _racas = [];

  @override
  void initState() {
    super.initState();
    _tutorSelecionadoId = widget.pet['tutorId'];
    _racaSelecionadaId = widget.pet['racaId'];
    _especieSelecionada = widget.pet['especie'];
    if (widget.pet['dataEntrada'] != null) {
      _dataEntrada = DateTime.parse(widget.pet['dataEntrada']);
      _dataEntradaController.text = DateFormat('dd/MM/yyyy').format(_dataEntrada!);
    }
    if (widget.pet['dataSaida'] != null) {
      _dataSaida = DateTime.parse(widget.pet['dataSaida']);
      _dataSaidaController.text = DateFormat('dd/MM/yyyy').format(_dataSaida!);
    }
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _isLoading = true);
    await _fetchTutores();
    await _fetchRacas(_especieSelecionada);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchTutores() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tutors'));
      if (mounted && response.statusCode == 200) {
        setState(() => _tutores = json.decode(response.body));
      } else if(mounted) {
        throw Exception('Falha ao carregar tutores');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao buscar tutores: ${e.toString()}');
    }
  }

  Future<void> _fetchRacas(String especie) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/racas/especie/$especie'));
      if (mounted && response.statusCode == 200) {
        setState(() => _racas = json.decode(response.body));
      } else if(mounted) {
        throw Exception('Falha ao carregar raças');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao buscar raças: ${e.toString()}');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isEntryDate) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: (isEntryDate ? _dataEntrada : _dataSaida) ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        if (isEntryDate) {
          _dataEntrada = picked;
          _dataEntradaController.text = formattedDate;
        } else {
          _dataSaida = picked;
          _dataSaidaController.text = formattedDate;
        }
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/pets/${widget.pet['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'tutorId': _tutorSelecionadoId, 'racaId': _racaSelecionadaId, 'especie': _especieSelecionada, 'dataEntrada': _dataEntrada?.toIso8601String(), 'dataSaida': _dataSaida?.toIso8601String()}),
      );
      if (mounted && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet atualizado com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else if (mounted) {
        throw Exception('Falha ao atualizar o pet. Código: ${response.statusCode}');
      }
    } catch(e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirPet() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/pets/${widget.pet['id']}'));
      if (mounted && response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet excluído com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else if (mounted) {
        throw Exception('Falha ao excluir o pet.');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
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
          content: const Text('Tem certeza que deseja excluir este pet?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _excluirPet();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    _dataEntradaController.dispose();
    _dataSaidaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Pet'),
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
                    DropdownButtonFormField<int>(
                      value: _tutorSelecionadoId,
                      decoration: const InputDecoration(labelText: 'Tutor', border: OutlineInputBorder()),
                      items: _tutores.map<DropdownMenuItem<int>>((tutor) => DropdownMenuItem<int>(value: tutor['id'], child: Text(tutor['nome']))).toList(),
                      onChanged: (value) => setState(() => _tutorSelecionadoId = value),
                      validator: (value) => value == null ? 'Selecione um tutor.' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text('Espécie:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(children: [
                      Expanded(child: RadioListTile<String>(title: const Text('Cachorro'), value: 'Cachorro', groupValue: _especieSelecionada, onChanged: (v) => setState(() { _especieSelecionada = v!; _fetchRacas(v); }))),
                      Expanded(child: RadioListTile<String>(title: const Text('Gato'), value: 'Gato', groupValue: _especieSelecionada, onChanged: (v) => setState(() { _especieSelecionada = v!; _fetchRacas(v); }))),
                    ]),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _racaSelecionadaId,
                      decoration: const InputDecoration(labelText: 'Raça', border: OutlineInputBorder()),
                      items: _racas.map<DropdownMenuItem<int>>((raca) => DropdownMenuItem<int>(value: raca['id'], child: Text(raca['nome']))).toList(),
                      onChanged: (value) => setState(() => _racaSelecionadaId = value),
                      validator: (value) => value == null ? 'Selecione uma raça.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _dataEntradaController, decoration: const InputDecoration(labelText: 'Data de Entrada', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () => _selectDate(context, true), validator: (v) => v == null || v.isEmpty ? 'Selecione a data de entrada.' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _dataSaidaController, decoration: const InputDecoration(labelText: 'Data de Saída (Opcional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () => _selectDate(context, false)),
                  ],
                ),
              ),
            ),
    );
  }
}