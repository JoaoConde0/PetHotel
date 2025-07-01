import 'package:flutter/material.dart';
import 'dart:convert'; // Necessário para codificar/decodificar JSON
import 'package:http/http.dart' as http; // Pacote para requisições HTTP

class TelaCadastroRaca extends StatefulWidget {
  const TelaCadastroRaca({super.key});

  @override
  State<TelaCadastroRaca> createState() => _TelaCadastroRacaState();
}

class _TelaCadastroRacaState extends State<TelaCadastroRaca> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String _especieSelecionada = 'Cachorro';
  bool _isLoading = false;

  final String _baseUrl = 'http://150.164.247.209:3333';  //SEMPRE MUDAR

  Future<void> _salvarRaca() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nomeRaca = _nomeController.text.trim();

    try {
      // 1. VERIFICAR SE A RAÇA JÁ EXISTE
      final checkUri = Uri.parse('$_baseUrl/racas/especie/$_especieSelecionada');
      final checkResponse = await http.get(checkUri);

      if (checkResponse.statusCode == 200) {
        final List<dynamic> racasExistentes = json.decode(checkResponse.body);
        final bool jaExiste = racasExistentes.any((raca) => raca['nome'].toString().toLowerCase() == nomeRaca.toLowerCase());

        if (jaExiste) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Essa raça já existe, tente outro nome.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      } else {
        throw Exception('Falha ao verificar raças existentes.');
      }

      // 2. SE NÃO EXISTE, CRIAR A NOVA RAÇA
      final createUri = Uri.parse('$_baseUrl/racas');
      final createResponse = await http.post(
        createUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nomeRaca,
          'especie': _especieSelecionada,
        }),
      );

      if (createResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Raça cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Volta para a tela anterior
      } else {
        throw Exception('Falha ao cadastrar a raça.');
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        title: const Text('Cadastrar Nova Raça'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selecione a espécie:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('Cachorro'),
                value: 'Cachorro',
                groupValue: _especieSelecionada,
                onChanged: (value) {
                  setState(() {
                    _especieSelecionada = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Gato'),
                value: 'Gato',
                groupValue: _especieSelecionada,
                onChanged: (value) {
                  setState(() {
                    _especieSelecionada = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Raça',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome da raça.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarRaca,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Salvar Raça'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}