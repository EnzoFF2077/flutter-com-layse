import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/app_scope.dart';
import '../models/contato.dart';
import '../utils/formatadores.dart';
import '../utils/validacoes_entrada.dart';
import '../widgets/foto_contato.dart';

class TelaEdicao extends StatefulWidget {
  final Contato? contato;

  const TelaEdicao({super.key, this.contato});

  @override
  State<TelaEdicao> createState() => _TelaEdicaoState();
}

class _TelaEdicaoState extends State<TelaEdicao> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final cidadeController = TextEditingController();
  final empresaController = TextEditingController();
  final observacoesController = TextEditingController();
  DateTime? nascimento;
  Uint8List? foto;
  late List<String> categorias;

  @override
  void initState() {
    super.initState();
    final contato = widget.contato;
    nomeController.text = contato?.nome ?? '';
    emailController.text = contato?.email ?? '';
    telefoneController.text = contato?.telefone ?? '';
    cidadeController.text = contato?.cidade ?? '';
    empresaController.text = contato?.empresa ?? '';
    observacoesController.text = contato?.observacoes ?? '';
    nascimento = contato?.dataNascimento;
    foto = contato?.foto;
    categorias = List<String>.from(contato?.categorias ?? const []);
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
      if (mounted) setState(() => foto = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a foto.')),
      );
    }
  }

  Future<void> escolherNascimento() async {
    final data = await showDatePicker(
      context: context,
      initialDate: nascimento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (data != null) setState(() => nascimento = data);
  }

  void salvar() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final contato = widget.contato;
    if (contato == null) {
      Navigator.pop(
        context,
        Contato(
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          telefone: telefoneController.text.trim(),
          cidade: cidadeController.text.trim(),
          empresa: empresaController.text.trim(),
          observacoes: observacoesController.text.trim(),
          dataNascimento: nascimento,
          foto: foto,
          categorias: categorias,
        ),
      );
      return;
    }
    contato.nome = nomeController.text.trim();
    contato.email = emailController.text.trim();
    contato.telefone = telefoneController.text.trim();
    contato.cidade = cidadeController.text.trim();
    contato.empresa = empresaController.text.trim();
    contato.observacoes = observacoesController.text.trim();
    contato.dataNascimento = nascimento;
    contato.foto = foto;
    contato.categorias = categorias;
    AppScope.of(context).alterar();
    Navigator.pop(context, contato);
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    cidadeController.dispose();
    empresaController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contato == null ? 'Novo Contato' : 'Editar Contato'),
        actions: [
          IconButton(
            onPressed: salvar,
            tooltip: 'Salvar',
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: FotoContato(foto: foto)),
            Center(
              child: TextButton.icon(
                onPressed: escolherFoto,
                icon: const Icon(Icons.photo_library),
                label: const Text('Alterar foto'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nomeController,
              inputFormatters: somenteTexto,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (valor) =>
                  validarSomenteTexto(valor, 'o nome', obrigatorio: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cidadeController,
              inputFormatters: somenteTexto,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                border: OutlineInputBorder(),
              ),
              validator: (valor) => validarSomenteTexto(valor, 'a cidade'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: empresaController,
              decoration: const InputDecoration(
                labelText: 'Empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.cake),
              title: const Text('Data de nascimento'),
              subtitle: Text(formatarData(nascimento)),
              trailing: nascimento == null
                  ? const Icon(Icons.calendar_month)
                  : IconButton(
                      onPressed: () => setState(() => nascimento = null),
                      icon: const Icon(Icons.close),
                    ),
              onTap: escolherNascimento,
            ),
            const SizedBox(height: 16),
            const Text(
              'Categorias',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: store.categorias.map((categoria) {
                return FilterChip(
                  label: Text(categoria),
                  selected: categorias.contains(categoria),
                  onSelected: (selecionada) {
                    setState(() {
                      selecionada
                          ? categorias.add(categoria)
                          : categorias.remove(categoria);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: observacoesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: salvar,
              icon: const Icon(Icons.save),
              label: const Text('Salvar contato'),
            ),
          ],
        ),
      ),
    );
  }
}
