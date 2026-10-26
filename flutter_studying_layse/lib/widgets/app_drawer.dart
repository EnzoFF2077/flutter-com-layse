import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String rotaAtual;

  const AppDrawer({super.key, required this.rotaAtual});

  void abrir(BuildContext context, String rota) {
    Navigator.pop(context);
    if (rota == rotaAtual) return;
    Navigator.pushReplacementNamed(context, rota);
  }

  @override
  Widget build(BuildContext context) {
    const itens = [
      ('/', 'Contatos', Icons.contacts),
      ('/favoritos', 'Favoritos', Icons.star),
      ('/categorias', 'Categorias', Icons.label),
      ('/grupos', 'Grupos', Icons.groups),
      ('/aniversarios', 'Aniversários', Icons.cake),
      ('/pesquisa', 'Pesquisa avançada', Icons.manage_search),
      ('/arquivos', 'Importar e exportar', Icons.import_export),
      ('/configuracoes', 'Configurações', Icons.settings),
    ];
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 38,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Agenda de Contatos',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: itens.map((item) {
                  return ListTile(
                    selected: rotaAtual == item.$1,
                    leading: Icon(item.$3),
                    title: Text(item.$2),
                    onTap: () => abrir(context, item.$1),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
