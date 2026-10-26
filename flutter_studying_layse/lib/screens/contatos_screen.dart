import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/contato.dart';
import '../utils/formatadores.dart';
import '../widgets/app_drawer.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/foto_contato.dart';
import 'detalhes_screen.dart';
import 'edicao_screen.dart';

class TelaListagem extends StatefulWidget {
  const TelaListagem({super.key});

  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  String busca = '';

  Future<void> novoContato() async {
    final contato = await Navigator.push<Contato>(
      context,
      MaterialPageRoute(builder: (context) => const TelaEdicao()),
    );
    if (!mounted || contato == null) return;
    AppScope.of(context).adicionarContato(contato);
  }

  Future<void> abrirContato(Contato contato) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaDetalhes(contato: contato)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final contatos = store.contatos.where((contato) {
      final termo = normalizar(busca.trim());
      return termo.isEmpty ||
          normalizar(contato.nome).contains(termo) ||
          normalizar(contato.email).contains(termo) ||
          contato.telefone.contains(termo);
    }).toList();
    contatos.sort((a, b) {
      if (store.preferencias.ordenacao == 'cadastro') {
        return b.dataCadastro.compareTo(a.dataCadastro);
      }
      return normalizar(a.nome).compareTo(normalizar(b.nome));
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Contatos')),
      drawer: const AppDrawer(rotaAtual: '/'),
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
              onChanged: (valor) => setState(() => busca = valor),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: contatos.isEmpty
                  ? EstadoVazio(
                      icone: Icons.person_search,
                      titulo: store.contatos.isEmpty
                          ? 'Nenhum contato cadastrado'
                          : 'Nenhum contato encontrado',
                      descricao: store.contatos.isEmpty
                          ? 'Use o botão + para cadastrar o primeiro contato.'
                          : 'Tente buscar usando outro termo.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: contatos.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final contato = contatos[index];
                        return ListTile(
                          leading: store.preferencias.exibirFotos
                              ? FotoContato(foto: contato.foto, raio: 24)
                              : null,
                          title: Text(contato.nome),
                          subtitle: Text(
                            contato.telefone.isEmpty
                                ? contato.email
                                : contato.telefone,
                          ),
                          trailing: contato.favorito
                              ? const Icon(Icons.star, color: Colors.amber)
                              : const Icon(Icons.chevron_right),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
