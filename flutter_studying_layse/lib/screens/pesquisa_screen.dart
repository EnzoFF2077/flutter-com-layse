import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/contato.dart';
import '../utils/formatadores.dart';
import '../utils/validacoes_entrada.dart';
import '../widgets/app_drawer.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/foto_contato.dart';
import 'detalhes_screen.dart';

class TelaPesquisaAvancada extends StatefulWidget {
  const TelaPesquisaAvancada({super.key});

  @override
  State<TelaPesquisaAvancada> createState() => _TelaPesquisaAvancadaState();
}

class _TelaPesquisaAvancadaState extends State<TelaPesquisaAvancada> {
  final cidadeController = TextEditingController();
  final empresaController = TextEditingController();
  final categorias = <String>{};
  DateTimeRange? periodo;
  bool pesquisou = false;

  List<Contato> filtrar(List<Contato> contatos) {
    if (!pesquisou) return [];
    final cidade = normalizar(cidadeController.text.trim());
    final empresa = normalizar(empresaController.text.trim());
    return contatos.where((contato) {
      final atendeCidade =
          cidade.isEmpty || normalizar(contato.cidade).contains(cidade);
      final atendeEmpresa =
          empresa.isEmpty || normalizar(contato.empresa).contains(empresa);
      final atendeCategorias =
          categorias.isEmpty || categorias.every(contato.categorias.contains);
      final data = DateTime(
        contato.dataCadastro.year,
        contato.dataCadastro.month,
        contato.dataCadastro.day,
      );
      final atendePeriodo =
          periodo == null ||
          (!data.isBefore(periodo!.start) && !data.isAfter(periodo!.end));
      return atendeCidade && atendeEmpresa && atendeCategorias && atendePeriodo;
    }).toList()..sort(
      (a, b) => normalizar(a.nome).compareTo(normalizar(b.nome)),
    );
  }

  Future<void> selecionarPeriodo() async {
    final selecionado = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: periodo,
    );
    if (selecionado != null) setState(() => periodo = selecionado);
  }

  void limpar() {
    cidadeController.clear();
    empresaController.clear();
    setState(() {
      categorias.clear();
      periodo = null;
      pesquisou = false;
    });
  }

  @override
  void dispose() {
    cidadeController.dispose();
    empresaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final resultados = filtrar(store.contatos);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisa Avançada'),
        actions: [
          IconButton(
            onPressed: limpar,
            tooltip: 'Limpar filtros',
            icon: const Icon(Icons.filter_alt_off),
          ),
        ],
      ),
      drawer: const AppDrawer(rotaAtual: '/pesquisa'),
      body: Column(
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            leading: const Icon(Icons.tune),
            title: const Text('Filtros'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              TextField(
                controller: cidadeController,
                inputFormatters: somenteTexto,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              TextField(
                controller: empresaController,
                decoration: const InputDecoration(
                  labelText: 'Empresa',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categorias',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: store.categorias.map((categoria) {
                    return FilterChip(
                      label: Text(categoria),
                      selected: categorias.contains(categoria),
                      onSelected: (valor) => setState(
                        () => valor
                            ? categorias.add(categoria)
                            : categorias.remove(categoria),
                      ),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range),
                title: const Text('Período de cadastro'),
                subtitle: Text(
                  periodo == null
                      ? 'Qualquer período'
                      : '${formatarData(periodo!.start)} até ${formatarData(periodo!.end)}',
                ),
                onTap: selecionarPeriodo,
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => pesquisou = true),
                  icon: const Icon(Icons.search),
                  label: const Text('Pesquisar'),
                ),
              ),
            ],
          ),
          Expanded(
            child: !pesquisou
                ? const EstadoVazio(
                    icone: Icons.manage_search,
                    titulo: 'Defina os filtros e pesquise',
                  )
                : resultados.isEmpty
                ? const EstadoVazio(
                    icone: Icons.search_off,
                    titulo: 'Nenhum contato encontrado',
                  )
                : ListView.builder(
                    itemCount: resultados.length,
                    itemBuilder: (context, index) {
                      final contato = resultados[index];
                      return ListTile(
                        leading: FotoContato(foto: contato.foto, raio: 22),
                        title: Text(contato.nome),
                        subtitle: Text(
                          [
                            contato.cidade,
                            contato.empresa,
                          ].where((item) => item.isNotEmpty).join(' • '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TelaDetalhes(contato: contato),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
