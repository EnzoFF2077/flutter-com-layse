import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/contato.dart';
import '../utils/formatadores.dart';
import '../widgets/app_drawer.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/foto_contato.dart';
import 'detalhes_screen.dart';

class TelaFavoritos extends StatelessWidget {
  const TelaFavoritos({super.key});

  Future<void> adicionar(
    BuildContext context,
    List<Contato> disponiveis,
  ) async {
    if (disponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há contatos disponíveis.')),
      );
      return;
    }
    final contato = await showDialog<Contato>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar favorito'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: disponiveis.length,
            itemBuilder: (context, index) {
              final contato = disponiveis[index];
              return ListTile(
                leading: FotoContato(foto: contato.foto, raio: 20),
                title: Text(contato.nome),
                onTap: () => Navigator.pop(context, contato),
              );
            },
          ),
        ),
      ),
    );
    if (contato == null || !context.mounted) return;
    contato.favorito = true;
    AppScope.of(context).alterar();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final favoritos =
        store.contatos.where((contato) => contato.favorito).toList()
          ..sort((a, b) => normalizar(a.nome).compareTo(normalizar(b.nome)));
    final disponiveis =
        store.contatos.where((contato) => !contato.favorito).toList()
          ..sort((a, b) => normalizar(a.nome).compareTo(normalizar(b.nome)));
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      drawer: const AppDrawer(rotaAtual: '/favoritos'),
      body: favoritos.isEmpty
          ? const EstadoVazio(
              icone: Icons.star_border,
              titulo: 'Nenhum contato favorito',
              descricao: 'Adicione seus contatos mais importantes.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final contato = favoritos[index];
                return ListTile(
                  leading: FotoContato(foto: contato.foto, raio: 24),
                  title: Text(contato.nome),
                  subtitle: Text(contato.telefone),
                  trailing: IconButton(
                    onPressed: () {
                      contato.favorito = false;
                      store.alterar();
                    },
                    icon: const Icon(Icons.star, color: Colors.amber),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaDetalhes(contato: contato),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => adicionar(context, disponiveis),
        child: const Icon(Icons.add),
      ),
    );
  }
}
