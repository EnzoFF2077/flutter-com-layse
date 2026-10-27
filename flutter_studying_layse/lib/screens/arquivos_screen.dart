import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../models/contato.dart';
import '../utils/csv.dart';
import '../utils/formatadores.dart';
import '../widgets/app_drawer.dart';

class TelaArquivos extends StatefulWidget {
  const TelaArquivos({super.key});

  @override
  State<TelaArquivos> createState() => _TelaArquivosState();
}

class _TelaArquivosState extends State<TelaArquivos> {
  bool processando = false;
  String? resultado;

  static const cabecalhos = [
    'nome',
    'email',
    'telefone',
    'cidade',
    'empresa',
    'data_nascimento',
    'data_cadastro',
    'categorias',
    'observacoes',
  ];

  Future<void> importar() async {
    final arquivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'json'],
    );
    if (arquivo == null) return;
    setState(() {
      processando = true;
      resultado = null;
    });
    try {
      final bytes = await arquivo.readAsBytes();
      final extensao = arquivo.name.split('.').last.toLowerCase();
      if (!mounted) return;
      if (extensao == 'json') {
        await restaurarBackup(bytes);
      } else {
        final linhas = extensao == 'xlsx'
            ? lerPlanilha(bytes)
            : lerCsv(utf8.decode(bytes, allowMalformed: true));
        final contatos = contatosDasLinhas(linhas);
        final store = AppScope.of(context);
        final existentes = store.contatos.map(chaveContato).toSet();
        final novos = contatos
            .where((contato) => existentes.add(chaveContato(contato)))
            .toList();
        for (final contato in novos) {
          contato.categorias = contato.categorias
              .map((categoria) {
                final existente = store.categorias.where(
                  (item) => normalizar(item) == normalizar(categoria),
                );
                if (existente.isNotEmpty) return existente.first;
                store.categorias.add(categoria);
                return categoria;
              })
              .toSet()
              .toList();
        }
        store.adicionarContatos(novos);
        setState(
          () => resultado =
              '${novos.length} contatos importados. ${contatos.length - novos.length} duplicados ignorados.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => resultado = 'Não foi possível importar o arquivo. Verifique o formato e os cabeçalhos.',
        );
      }
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  Future<void> restaurarBackup(Uint8List bytes) async {
    final dados = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar backup'),
        content: const Text(
          'A restauração substituirá os dados atuais. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmar != true) {
      setState(() => resultado = 'Restauração cancelada.');
      return;
    }
    AppScope.of(context).aplicarJson(dados);
    setState(() => resultado = 'Backup restaurado com sucesso.');
  }

  List<List<String>> lerPlanilha(Uint8List bytes) {
    final arquivo = xlsx.Excel.decodeBytes(bytes);
    if (arquivo.tables.isEmpty) return [];
    final tabela = arquivo.tables.values.first;
    return tabela.rows.map((linha) => linha.map(valorCelula).toList()).toList();
  }

  String valorCelula(xlsx.Data? celula) {
    final valor = celula?.value;
    return switch (valor) {
      null => '',
      xlsx.TextCellValue() => valor.value.toString(),
      xlsx.IntCellValue() => valor.value.toString(),
      xlsx.DoubleCellValue() => valor.value.toString(),
      xlsx.BoolCellValue() => valor.value.toString(),
      xlsx.DateCellValue() => valor.asDateTimeLocal().toIso8601String(),
      xlsx.DateTimeCellValue() => valor.asDateTimeLocal().toIso8601String(),
      xlsx.TimeCellValue() => valor.asDuration().toString(),
      xlsx.FormulaCellValue() => valor.formula.toString(),
    };
  }

  List<Contato> contatosDasLinhas(List<List<String>> linhas) {
    if (linhas.length < 2) return [];
    final indices = <String, int>{};
    for (var i = 0; i < linhas.first.length; i++) {
      final nome = normalizar(linhas.first[i].replaceAll('\ufeff', '').trim())
          .replaceAll(' ', '_')
          .replaceAll('-', '_');
      indices[nome] = i;
    }
    String campo(List<String> linha, List<String> nomes) {
      for (final nome in nomes) {
        final indice = indices[nome];
        if (indice != null && indice < linha.length) {
          return linha[indice].trim();
        }
      }
      return '';
    }

    return linhas
        .skip(1)
        .map((linha) {
          final categorias = campo(linha, ['categorias', 'categoria'])
              .split(RegExp(r'[|,;]'))
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();
          return Contato(
            nome: campo(linha, ['nome', 'name']),
            email: campo(linha, ['email', 'e_mail']),
            telefone: campo(linha, ['telefone', 'celular', 'phone']),
            cidade: campo(linha, ['cidade', 'city']),
            empresa: campo(linha, ['empresa', 'company']),
            dataNascimento: lerData(
              campo(linha, ['data_nascimento', 'nascimento', 'aniversario']),
            ),
            dataCadastro:
                lerData(campo(linha, ['data_cadastro', 'cadastro'])) ??
                DateTime.now(),
            categorias: categorias,
            observacoes: campo(linha, ['observacoes', 'observacao', 'notas']),
          );
        })
        .where((contato) => contato.nome.isNotEmpty)
        .toList();
  }

  String chaveContato(Contato contato) {
    final email = normalizar(contato.email.trim());
    final telefone = contato.telefone.replaceAll(RegExp(r'\D'), '');
    if (email.isNotEmpty) return 'email:$email';
    if (telefone.isNotEmpty) return 'telefone:$telefone';
    return 'nome:${normalizar(contato.nome)}';
  }

  List<List<String>> linhasParaExportacao(List<Contato> contatos) {
    return [
      cabecalhos,
      ...contatos.map(
        (contato) => [
          contato.nome,
          contato.email,
          contato.telefone,
          contato.cidade,
          contato.empresa,
          contato.dataNascimento?.toIso8601String() ?? '',
          contato.dataCadastro.toIso8601String(),
          contato.categorias.join('|'),
          contato.observacoes,
        ],
      ),
    ];
  }

  Future<void> exportarCsv() async {
    final linhas = linhasParaExportacao(AppScope.of(context).contatos);
    await salvar(
      'contatos.csv',
      Uint8List.fromList(utf8.encode('\ufeff${gerarCsv(linhas)}')),
    );
  }

  Future<void> exportarExcel() async {
    setState(() => processando = true);
    try {
      final documento = xlsx.Excel.createExcel();
      final planilha = documento['Contatos'];
      for (final linha in linhasParaExportacao(AppScope.of(context).contatos)) {
        planilha.appendRow(linha.map(xlsx.TextCellValue.new).toList());
      }
      documento.delete('Sheet1');
      final bytes = documento.encode();
      if (bytes == null) throw StateError('Falha ao gerar planilha');
      await salvar('contatos.xlsx', Uint8List.fromList(bytes));
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  Future<void> exportarBackup() async {
    final conteudo = AppScope.of(context).gerarBackup();
    await salvar(
      'backup_agenda.json',
      Uint8List.fromList(utf8.encode(conteudo)),
    );
  }

  Future<void> salvar(String nome, Uint8List bytes) async {
    try {
      final destino = await FilePicker.saveFile(fileName: nome, bytes: bytes);
      if (!mounted || destino == null) return;
      setState(() => resultado = 'Arquivo salvo com sucesso.');
    } catch (_) {
      if (mounted) {
        setState(() => resultado = 'Não foi possível salvar o arquivo.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = AppScope.of(context).contatos.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Importação e Exportação')),
      drawer: const AppDrawer(rotaAtual: '/arquivos'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Importar contatos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecione um arquivo CSV ou Excel com a primeira linha contendo os cabeçalhos. Também é possível restaurar um backup JSON.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: processando ? null : importar,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Selecionar arquivo'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Exportar contatos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$total ${total == 1 ? 'contato disponível' : 'contatos disponíveis'} para exportação.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: processando ? null : exportarCsv,
                    icon: const Icon(Icons.table_rows),
                    label: const Text('Exportar CSV'),
                  ),
                  OutlinedButton.icon(
                    onPressed: processando ? null : exportarExcel,
                    icon: const Icon(Icons.grid_on),
                    label: const Text('Exportar Excel'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: processando ? null : exportarBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('Gerar backup completo'),
                  ),
                ],
              ),
            ),
          ),
          if (processando)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (resultado != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(resultado!),
                trailing: IconButton(
                  onPressed: () => setState(() => resultado = null),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
