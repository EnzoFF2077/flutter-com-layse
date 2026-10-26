import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../utils/formatadores.dart';
import '../widgets/app_drawer.dart';

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final preferencias = store.preferencias;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      drawer: const AppDrawer(rotaAtual: '/configuracoes'),
      body: ListView(
        children: [
          const _Titulo('Aparência'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            subtitle: const Text('Escolha a aparência do aplicativo'),
            trailing: DropdownButton<ThemeMode>(
              value: preferencias.tema,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Sistema'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Escuro')),
              ],
              onChanged: (valor) {
                if (valor == null) return;
                preferencias.tema = valor;
                store.alterar();
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.account_circle_outlined),
            title: const Text('Exibir fotos'),
            subtitle: const Text('Mostrar fotos na lista de contatos'),
            value: preferencias.exibirFotos,
            onChanged: (valor) {
              preferencias.exibirFotos = valor;
              store.alterar();
            },
          ),
          const Divider(),
          const _Titulo('Backup'),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Backup automático'),
            subtitle: Text(
              preferencias.ultimoBackup == null
                  ? 'Mantém uma cópia local após cada alteração'
                  : 'Último backup: ${formatarData(preferencias.ultimoBackup)}',
            ),
            value: preferencias.backupAutomatico,
            onChanged: (valor) {
              preferencias.backupAutomatico = valor;
              store.alterar();
            },
          ),
          const Divider(),
          const _Titulo('Preferências'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Lembrete de aniversário'),
            subtitle: const Text('Antecedência para destacar datas próximas'),
            trailing: DropdownButton<int>(
              value: preferencias.diasLembrete,
              items: const [1, 3, 7, 15, 30]
                  .map(
                    (dias) => DropdownMenuItem(
                      value: dias,
                      child: Text('$dias dias'),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor == null) return;
                preferencias.diasLembrete = valor;
                store.alterar();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Ordenar contatos'),
            trailing: DropdownButton<String>(
              value: preferencias.ordenacao,
              items: const [
                DropdownMenuItem(value: 'nome', child: Text('Nome')),
                DropdownMenuItem(value: 'cadastro', child: Text('Cadastro')),
              ],
              onChanged: (valor) {
                if (valor == null) return;
                preferencias.ordenacao = valor;
                store.alterar();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;

  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        texto,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
