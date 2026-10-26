import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../utils/formatadores.dart';
import '../utils/validacoes_entrada.dart';
import '../widgets/app_drawer.dart';
import '../widgets/foto_contato.dart';

class TelaCategorias extends StatefulWidget {
  const TelaCategorias({super.key});

  @override
  State<TelaCategorias> createState() => _TelaCategoriasState();
}

class _TelaCategoriasState extends State<TelaCategorias> {
  final controller = TextEditingController();

  void criar() {
    final store = AppScope.of(context);
    final nome = controller.text.trim();
    if (nome.isEmpty) return;
    final erro = validarSomenteTexto(nome, 'a categoria');
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }
    if (store.categorias.any((item) => normalizar(item) == normalizar(nome))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Essa categoria já existe.')),
      );
      return;
    }
    store.adicionarCategoria(nome);
    controller.clear();
  }

  Future<void> excluir(String categoria) async {
    final store = AppScope.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja excluir a categoria $categoria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    store.categorias.remove(categoria);
    for (final contato in store.contatos) {
      contato.categorias.remove(categoria);
    }
    store.alterar();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final contatos = store.contatos.toList()
      ..sort((a, b) => normalizar(a.nome).compareTo(normalizar(b.nome)));
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      drawer: const AppDrawer(rotaAtual: '/categorias'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    inputFormatters: somenteTexto,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nova categoria',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => criar(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: criar, child: const Text('Criar')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: store.categorias.length,
                itemBuilder: (context, index) {
                  final categoria = store.categorias[index];
                  final total = contatos
                      .where(
                        (contato) => contato.categorias.contains(categoria),
                      )
                      .length;
                  return ExpansionTile(
                    leading: const Icon(Icons.label),
                    title: Text(categoria),
                    subtitle: Text(
                      '$total ${total == 1 ? 'contato' : 'contatos'}',
                    ),
                    trailing: IconButton(
                      onPressed: () => excluir(categoria),
                      icon: const Icon(Icons.delete_outline),
                    ),
                    children: contatos.isEmpty
                        ? [
                            const ListTile(
                              title: Text('Nenhum contato cadastrado.'),
                            ),
                          ]
                        : contatos.map((contato) {
                            return CheckboxListTile(
                              value: contato.categorias.contains(categoria),
                              secondary: FotoContato(
                                foto: contato.foto,
                                raio: 20,
                              ),
                              title: Text(contato.nome),
                              onChanged: (valor) {
                                valor == true
                                    ? contato.categorias.add(categoria)
                                    : contato.categorias.remove(categoria);
                                store.alterar();
                              },
                            );
                          }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
