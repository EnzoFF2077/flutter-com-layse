import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../utils/formatadores.dart';
import '../widgets/app_drawer.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/foto_contato.dart';

class TelaAniversarios extends StatelessWidget {
  const TelaAniversarios({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final agora = DateTime.now();
    final aniversariantes =
        store.contatos.where((contato) {
          return contato.dataNascimento?.month == agora.month;
        }).toList()..sort(
          (a, b) => a.dataNascimento!.day.compareTo(b.dataNascimento!.day),
        );
    final proximos =
        store.contatos.where((contato) {
          final nascimento = contato.dataNascimento;
          if (nascimento == null) return false;
          final dias = diasAteProximoAniversario(nascimento, agora);
          return dias <= store.preferencias.diasLembrete;
        }).toList()..sort(
          (a, b) => diasAteProximoAniversario(
            a.dataNascimento!,
            agora,
          ).compareTo(diasAteProximoAniversario(b.dataNascimento!, agora)),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Aniversários')),
      drawer: const AppDrawer(rotaAtual: '/aniversarios'),
      body: store.contatos.every((contato) => contato.dataNascimento == null)
          ? const EstadoVazio(
              icone: Icons.cake_outlined,
              titulo: 'Nenhum aniversário informado',
              descricao: 'Edite um contato e informe a data de nascimento.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Lembretes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (proximos.isEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: Text(
                        'Nenhum aniversário nos próximos ${store.preferencias.diasLembrete} dias',
                      ),
                    ),
                  )
                else
                  ...proximos.map((contato) {
                    final dias = diasAteProximoAniversario(
                      contato.dataNascimento!,
                      agora,
                    );
                    return Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: ListTile(
                        leading: FotoContato(foto: contato.foto, raio: 22),
                        title: Text(contato.nome),
                        subtitle: Text(
                          dias == 0
                              ? 'Aniversário hoje'
                              : 'Aniversário em $dias ${dias == 1 ? 'dia' : 'dias'}',
                        ),
                        trailing: const Icon(Icons.notifications_active),
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                Text(
                  'Aniversariantes do mês',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (aniversariantes.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text('Nenhum aniversariante neste mês.'),
                    ),
                  )
                else
                  ...aniversariantes.map((contato) {
                    return ListTile(
                      leading: FotoContato(foto: contato.foto, raio: 22),
                      title: Text(contato.nome),
                      subtitle: Text(formatarData(contato.dataNascimento)),
                      trailing: Text('Dia ${contato.dataNascimento!.day}'),
                    );
                  }),
              ],
            ),
    );
  }
}
