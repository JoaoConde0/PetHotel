import 'package:flutter/material.dart';
import 'dart:convert'; // Necessário para codificar/decodificar JSON
import 'package:http/http.dart' as http; // Pacote para requisições HTTP

class TelaCadastroTutor extends StatefulWidget {
  const TelaCadastroTutor({super.key});

  @override
  State<TelaCadastroTutor> createState() => _TelaCadastroTutorState();
}

class _TelaCadastroTutorState extends State<TelaCadastroTutor> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _contatoController = TextEditingController();
  String _sexoSelecionado = 'Feminino';
  String? _metodoPagamentoSelecionado = 'Dinheiro';
  bool _isLoading = false;

  final List<String> _metodosPagamento = ['Dinheiro', 'Pix', 'Crédito', 'Débito'];
  final String _baseUrl = 'http://000.000.000:3333';  //SEMPRE MUDAR

  Future<void> _salvarTutor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$_baseUrl/tutors');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': _nomeController.text.trim(),
          'contato': _contatoController.text.trim(),
          'sexo': _sexoSelecionado,
          'metodoPagamento': _metodoPagamentoSelecionado,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutor cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Falha ao cadastrar o tutor. Código: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: const Text('Cadastrar Novo Tutor'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Por favor, insira o nome.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contatoController,
                  decoration: const InputDecoration(
                    labelText: 'Contato (Telefone)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Por favor, insira o contato.' : null,
                ),
                const SizedBox(height: 20),
                const Text('Sexo:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                RadioListTile<String>(
                  title: const Text('Feminino'),
                  value: 'Feminino',
                  groupValue: _sexoSelecionado,
                  onChanged: (value) => setState(() => _sexoSelecionado = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Masculino'),
                  value: 'Masculino',
                  groupValue: _sexoSelecionado,
                  onChanged: (value) => setState(() => _sexoSelecionado = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _metodoPagamentoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Método de Pagamento',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                  ),
                  items: _metodosPagamento.map((String metodo) {
                    return DropdownMenuItem<String>(
                      value: metodo,
                      child: Text(metodo),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _metodoPagamentoSelecionado = newValue),
                  validator: (value) => value == null ? 'Por favor, selecione um método.' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvarTutor,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar Tutor'),
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