import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/contato.dart';
import '../utils/formatadores.dart';
import '../widgets/foto_contato.dart';
import 'edicao_screen.dart';

class TelaDetalhes extends StatelessWidget {
  final Contato contato;

  const TelaDetalhes({super.key, required this.contato});

  Future<void> excluir(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir contato'),
        content: Text('Deseja excluir ${contato.nome}?'),
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
    if (confirmar != true || !context.mounted) return;
    AppScope.of(context).removerContato(contato);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Contato'),
        actions: [
          IconButton(
            onPressed: () {
              contato.favorito = !contato.favorito;
              store.alterar();
            },
            tooltip: contato.favorito
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            icon: Icon(contato.favorito ? Icons.star : Icons.star_border),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaEdicao(contato: contato),
              ),
            ),
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: FotoContato(foto: contato.foto)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              contato.nome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          _Info(
            icone: Icons.phone,
            titulo: 'Telefone',
            valor: contato.telefone,
          ),
          _Info(icone: Icons.email, titulo: 'E-mail', valor: contato.email),
          _Info(
            icone: Icons.location_city,
            titulo: 'Cidade',
            valor: contato.cidade,
          ),
          _Info(
            icone: Icons.business,
            titulo: 'Empresa',
            valor: contato.empresa,
          ),
          _Info(
            icone: Icons.cake,
            titulo: 'Aniversário',
            valor: formatarData(contato.dataNascimento),
          ),
          _Info(
            icone: Icons.event,
            titulo: 'Data de cadastro',
            valor: formatarData(contato.dataCadastro),
          ),
          _Info(
            icone: Icons.label,
            titulo: 'Categorias',
            valor: contato.categorias.isEmpty
                ? 'Nenhuma'
                : contato.categorias.join(', '),
          ),
          _Info(
            icone: Icons.notes,
            titulo: 'Observações',
            valor: contato.observacoes,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => excluir(context),
            icon: const Icon(Icons.delete),
            label: const Text('Excluir contato'),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _Info({required this.icone, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titulo),
      subtitle: Text(valor.trim().isEmpty ? 'Não informado' : valor),
    );
  }
}
