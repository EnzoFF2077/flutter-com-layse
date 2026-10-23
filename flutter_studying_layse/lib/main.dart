import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 185, 51, 41),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const TelaListagem(),
    );
  }
}

// Idealmente, seria colocar isso em um lugar separado (eu acredito) como faço em DDD e MVC, viu teteu?
class Contato {
  String nome;
  String email;
  String telefone;
  String observacoes;
  Uint8List? foto;

  Contato({
    required this.nome,
    required this.email,
    required this.telefone,
    this.observacoes = '',
    this.foto,
  });
}

class FotoContato extends StatelessWidget {
  final Uint8List? foto;
  final double raio;

  const FotoContato({super.key, this.foto, this.raio = 50});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: raio,
      backgroundColor: Colors.grey[300],
      backgroundImage: foto == null ? null : MemoryImage(foto!),
      child: foto == null
          ? Icon(Icons.person, size: raio, color: Colors.white)
          : null,
    );
  }
}

class TelaListagem extends StatefulWidget {
  const TelaListagem({super.key});

  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  final List<Contato> contatos = [];
  String busca = '';

  String normalizar(String texto) { // Eu acho que isso aqui não e2 lé uma ideia mto boa. Porém... Foi o quê resolveu meu problema de pesquisa
    return texto
        .toLowerCase()
        .replaceAll(RegExp('[áàâãä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c');
  }

  Future<void> novoContato() async {
    final contato = await Navigator.push<Contato>(
      context,
      MaterialPageRoute(builder: (context) => const TelaEdicao()),
    );
    if (!mounted || contato == null) return;
    setState(() {
      contatos.add(contato);
    });
  }

  Future<void> abrirContato(Contato contato) async {
    final excluir = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => TelaDetalhes(contato: contato)),
    );
    if (!mounted) return;
    setState(() {
      if (excluir == true) contatos.remove(contato);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contatosFiltrados = contatos.where((contato) {
      return normalizar(contato.nome).contains(busca) ||
          normalizar(contato.email).contains(busca) ||
          contato.telefone.contains(busca);
    }).toList();
    contatosFiltrados.sort(
      (a, b) => normalizar(a.nome).compareTo(normalizar(b.nome)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Contatos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nome, e-mail ou telefone',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  busca = normalizar(valor.trim());
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: contatosFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        contatos.isEmpty
                            ? 'Nenhum contato cadastrado.'
                            : 'Nenhum contato encontrado.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: contatosFiltrados.length,
                      itemBuilder: (context, index) {
                        final contato = contatosFiltrados[index];
                        return ListTile(
                          leading: FotoContato(foto: contato.foto, raio: 24),
                          title: Text(contato.nome),
                          subtitle: Text(contato.telefone),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => abrirContato(contato),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: novoContato,
        tooltip: 'Novo contato',
        child: const Icon(Icons.add, color: Colors.red),
      ),
    );
  }
}

class TelaDetalhes extends StatefulWidget {
  final Contato contato;

  const TelaDetalhes({super.key, required this.contato});

  @override
  State<TelaDetalhes> createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  Future<void> editarContato() async {
    await Navigator.push<Contato>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaEdicao(contato: widget.contato),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> excluirContato() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir contato'),
        content: const Text('Deseja excluir este contato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmar == true) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final contato = widget.contato;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Contato')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: FotoContato(foto: contato.foto)),
            const SizedBox(height: 20),
            ListTile(title: const Text('Nome'), subtitle: Text(contato.nome)),
            ListTile(
              title: const Text('E-mail'),
              subtitle: Text(contato.email),
            ),
            ListTile(
              title: const Text('Telefone'),
              subtitle: Text(contato.telefone),
            ),
            ListTile(
              title: const Text('Observações'),
              subtitle: Text(
                contato.observacoes.isEmpty
                    ? 'Sem observações.'
                    : contato.observacoes,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: editarContato,
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
            ),
            TextButton.icon(
              onPressed: excluirContato,
              icon: const Icon(Icons.delete),
              label: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }
}

// Professora, eu botei o formulário para funcionar também como cadastro, pois achei que ficaria mais legal
class TelaEdicao extends StatefulWidget {
  final Contato? contato;

  const TelaEdicao({super.key, this.contato});

  @override
  State<TelaEdicao> createState() => _TelaEdicaoState();
}

class _TelaEdicaoState extends State<TelaEdicao> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final observacoesController = TextEditingController();
  Uint8List? foto;

  @override
  void initState() {
    super.initState();
    final contato = widget.contato;
    if (contato != null) {
      nomeController.text = contato.nome;
      emailController.text = contato.email;
      telefoneController.text = contato.telefone;
      observacoesController.text = contato.observacoes;
      foto = contato.foto;
    }
  }

  Future<void> escolherFoto() async {
    try {
      final imagem = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (imagem == null) return;
      final bytes = await imagem.readAsBytes();
      if (!mounted) return;
      setState(() {
        foto = bytes;
      });
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a foto.')),
      );
    }
  }

  void salvarContato() {
    if (nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do contato.')),
      );
      return;
    }
    // Só vai salvar se clicar em salvar
    final contato =
        widget.contato ?? Contato(nome: '', email: '', telefone: '');
    contato.nome = nomeController.text.trim();
    contato.email = emailController.text.trim();
    contato.telefone = telefoneController.text.trim();
    contato.observacoes = observacoesController.text.trim();
    contato.foto = foto;
    Navigator.pop(context, contato);
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contato == null ? 'Novo Contato' : 'Editar Contato'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          children: [
            FotoContato(foto: foto),
            TextButton.icon(
              onPressed: escolherFoto,
              icon: const Icon(Icons.photo_library),
              label: const Text('Alterar foto'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: observacoesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: salvarContato,
        tooltip: 'Salvar',
        child: const Icon(Icons.save, color: Colors.red),
      ),
    );
  }
}
