import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/grupo.dart';
import '../utils/formatadores.dart';
import '../utils/validacoes_entrada.dart';
import '../widgets/app_drawer.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/foto_contato.dart';

class TelaGrupos extends StatefulWidget {
  const TelaGrupos({super.key});

  @override
  State<TelaGrupos> createState() => _TelaGruposState();
}

class _TelaGruposState extends State<TelaGrupos> {
  Future<void> criarGrupo() async {
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo grupo'),
        content: TextField(
          controller: controller,
          inputFormatters: somenteTexto,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome do grupo'),
          onSubmitted: (valor) => Navigator.pop(context, valor.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (nome == null || nome.isEmpty || !mounted) return;
    final erro = validarSomenteTexto(nome, 'o nome do grupo');
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }
    final store = AppScope.of(context);
    if (store.grupos.any(
      (grupo) => normalizar(grupo.nome) == normalizar(nome),
    )) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Esse grupo já existe.')));
      return;
    }
    store.adicionarGrupo(Grupo(nome: nome));
  }

  Future<void> excluirGrupo(Grupo grupo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir grupo'),
        content: Text('Deseja excluir o grupo ${grupo.nome}?'),
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
    if (confirmar == true && mounted) AppScope.of(context).removerGrupo(grupo);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final contatos = store.contatos.toList()
      ..sort((a, b) => normalizar(a.nome).compareTo(normalizar(b.nome)));
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
      drawer: const AppDrawer(rotaAtual: '/grupos'),
      body: store.grupos.isEmpty
          ? const EstadoVazio(
              icone: Icons.groups_outlined,
              titulo: 'Nenhum grupo criado',
              descricao: 'Crie um grupo e organize seus contatos.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: store.grupos.length,
              itemBuilder: (context, index) {
                final grupo = store.grupos[index];
                return Card(
                  child: ExpansionTile(
                    leading: const CircleAvatar(child: Icon(Icons.groups)),
                    title: Text(grupo.nome),
                    subtitle: Text(
                      '${grupo.membros.length} ${grupo.membros.length == 1 ? 'membro' : 'membros'}',
                    ),
                    trailing: IconButton(
                      onPressed: () => excluirGrupo(grupo),
                      icon: const Icon(Icons.delete_outline),
                    ),
                    children: contatos.isEmpty
                        ? [
                            const ListTile(
                              title: Text(
                                'Cadastre contatos para adicioná-los ao grupo.',
                              ),
                            ),
                          ]
                        : contatos.map((contato) {
                            return CheckboxListTile(
                              value: grupo.membros.contains(contato.id),
                              secondary: FotoContato(
                                foto: contato.foto,
                                raio: 20,
                              ),
                              title: Text(contato.nome),
                              subtitle: Text(contato.telefone),
                              onChanged: (valor) {
                                valor == true
                                    ? grupo.membros.add(contato.id)
                                    : grupo.membros.remove(contato.id);
                                store.alterar();
                              },
                            );
                          }).toList(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: criarGrupo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
