import 'package:flutter/material.dart';
import 'dart:convert'; // Necessário para codificar/decodificar JSON
import 'package:http/http.dart' as http; // Pacote para requisições HTTP
import 'package:intl/intl.dart'; // Para formatação de datas

class TelaCadastroPet extends StatefulWidget {
  const TelaCadastroPet({super.key});

  @override
  State<TelaCadastroPet> createState() => _TelaCadastroPetState();
}

class _TelaCadastroPetState extends State<TelaCadastroPet> {
  final _formKey = GlobalKey<FormState>();
  final String _baseUrl = 'http://150.164.247.209:3333';  //SEMPRE MUDAR

  // Controladores e Variáveis de Estado
  bool _isLoading = true;
  int? _tutorSelecionadoId;
  int? _racaSelecionadaId;
  String _especieSelecionada = 'Cachorro';
  DateTime? _dataEntrada;
  DateTime? _dataSaida;
  final _dataEntradaController = TextEditingController();
  final _dataSaidaController = TextEditingController();

  // Listas para os Dropdowns
  List<dynamic> _tutores = [];
  List<dynamic> _racas = [];

  @override
  void initState() {
    super.initState();
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
      if (response.statusCode == 200) {
        setState(() => _tutores = json.decode(response.body));
      } else {
        throw Exception('Falha ao carregar tutores');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao buscar tutores: ${e.toString()}');
    }
  }

  Future<void> _fetchRacas(String especie) async {
    // Reseta a raça selecionada ao trocar de espécie
    setState(() => _racaSelecionadaId = null);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/racas/especie/$especie'));
      if (response.statusCode == 200) {
        setState(() => _racas = json.decode(response.body));
      } else {
        throw Exception('Falha ao carregar raças');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao buscar raças: ${e.toString()}');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isEntryDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
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

  Future<void> _salvarPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/pets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tutorId': _tutorSelecionadoId,
          'racaId': _racaSelecionadaId,
          'especie': _especieSelecionada,
          'dataEntrada': _dataEntrada?.toIso8601String(),
          'dataSaida': _dataSaida?.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet cadastrado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Falha ao cadastrar o pet. Código: ${response.statusCode}');
      }

    } catch(e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
        title: const Text('Cadastrar Novo Pet'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown Tutor
                      DropdownButtonFormField<int>(
                        value: _tutorSelecionadoId,
                        decoration: const InputDecoration(labelText: 'Tutor', border: OutlineInputBorder()),
                        items: [
                          ..._tutores.map<DropdownMenuItem<int>>((tutor) {
                            return DropdownMenuItem<int>(value: tutor['id'], child: Text(tutor['nome']));
                          }).toList(),
                          DropdownMenuItem<int>(
                            value: -1, // Valor especial para "Adicionar novo"
                            child: Text('+ Adicionar novo tutor...', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == -1) {
                            await Navigator.pushNamed(context, '/novo-tutor');
                            _fetchTutores(); // Recarrega os tutores após voltar
                          } else {
                            setState(() => _tutorSelecionadoId = value);
                          }
                        },
                        validator: (value) => value == null ? 'Selecione um tutor.' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      // Radio Espécie
                      const Text('Espécie:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Cachorro'),
                              value: 'Cachorro',
                              groupValue: _especieSelecionada,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _especieSelecionada = value);
                                  _fetchRacas(value);
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Gato'),
                              value: 'Gato',
                              groupValue: _especieSelecionada,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _especieSelecionada = value);
                                  _fetchRacas(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Raça
                      DropdownButtonFormField<int>(
                        value: _racaSelecionadaId,
                        decoration: const InputDecoration(labelText: 'Raça', border: OutlineInputBorder()),
                        items: [
                          ..._racas.map<DropdownMenuItem<int>>((raca) {
                            return DropdownMenuItem<int>(value: raca['id'], child: Text(raca['nome']));
                          }).toList(),
                          DropdownMenuItem<int>(
                            value: -1, // Valor especial
                            child: Text('+ Adicionar nova raça...', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == -1) {
                            await Navigator.pushNamed(context, '/nova-raca');
                            _fetchRacas(_especieSelecionada); // Recarrega as raças
                          } else {
                            setState(() => _racaSelecionadaId = value);
                          }
                        },
                        validator: (value) => value == null ? 'Selecione uma raça.' : null,
                      ),
                      const SizedBox(height: 16),

                      // Data de Entrada
                      TextFormField(
                        controller: _dataEntradaController,
                        decoration: const InputDecoration(labelText: 'Data de Entrada', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                        readOnly: true,
                        onTap: () => _selectDate(context, true),
                        validator: (value) => value == null || value.isEmpty ? 'Selecione a data de entrada.' : null,
                      ),
                      const SizedBox(height: 16),

                      // Data de Saída
                      TextFormField(
                        controller: _dataSaidaController,
                        decoration: const InputDecoration(labelText: 'Data de Saída (Opcional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                        readOnly: true,
                        onTap: () => _selectDate(context, false),
                      ),
                      const SizedBox(height: 30),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _salvarPet,
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Salvar Pet'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}