import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contato.dart';
import '../models/grupo.dart';
import '../models/preferencias.dart';

class AppStore extends ChangeNotifier {
  static const _stateKey = 'agenda_estado_v2';
  static const _automaticBackupKey = 'agenda_backup_automatico';
  static const _corruptedStateKey = 'agenda_estado_corrompido';
  SharedPreferences? _storage;

  final List<Contato> contatos = [];
  final List<String> categorias = ['Família', 'Amigos', 'Trabalho', 'Clientes'];
  final List<Grupo> grupos = [];
  Preferencias preferencias = Preferencias();

  Future<void> carregar() async {
    _storage = await SharedPreferences.getInstance();
    final value = _storage!.getString(_stateKey);
    if (value == null || value.isEmpty) return;
    try {
      aplicarJson(jsonDecode(value) as Map<String, dynamic>, notificar: false);
    } catch (_) {
      await _storage!.setString(_corruptedStateKey, value);
    }
  }

  Map<String, dynamic> toJson() => {
    'versao': 2,
    'contatos': contatos.map((contato) => contato.toJson()).toList(),
    'categorias': categorias,
    'grupos': grupos.map((grupo) => grupo.toJson()).toList(),
    'preferencias': preferencias.toJson(),
  };

  String gerarBackup() => jsonEncode(toJson());

  void aplicarJson(Map<String, dynamic> json, {bool notificar = true}) {
    final novosContatos = (json['contatos'] as List? ?? const [])
        .map((item) => Contato.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final novasCategorias = List<String>.from(json['categorias'] ?? const []);
    if (novasCategorias.isEmpty) {
      novasCategorias.addAll(['Família', 'Amigos', 'Trabalho', 'Clientes']);
    }
    final novosGrupos = (json['grupos'] as List? ?? const [])
        .map((item) => Grupo.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final preferenciasJson = json['preferencias'];
    final novasPreferencias = preferenciasJson is Map
        ? Preferencias.fromJson(Map<String, dynamic>.from(preferenciasJson))
        : preferencias;

    contatos
      ..clear()
      ..addAll(novosContatos);
    categorias
      ..clear()
      ..addAll(novasCategorias);
    grupos
      ..clear()
      ..addAll(novosGrupos);
    preferencias = novasPreferencias;
    if (notificar) alterar();
  }

  void adicionarContato(Contato contato) {
    contatos.add(contato);
    alterar();
  }

  void removerContato(Contato contato) {
    contatos.remove(contato);
    for (final grupo in grupos) {
      grupo.membros.remove(contato.id);
    }
    alterar();
  }

  void adicionarContatos(Iterable<Contato> novos) {
    contatos.addAll(novos);
    alterar();
  }

  void adicionarCategoria(String categoria) {
    categorias.add(categoria);
    alterar();
  }

  void adicionarGrupo(Grupo grupo) {
    grupos.add(grupo);
    alterar();
  }

  void removerGrupo(Grupo grupo) {
    grupos.remove(grupo);
    alterar();
  }

  void alterar() {
    notifyListeners();
    _salvar();
  }

  Future<void> _salvar() async {
    _storage ??= await SharedPreferences.getInstance();
    final conteudo = gerarBackup();
    await _storage!.setString(_stateKey, conteudo);
    if (preferencias.backupAutomatico) {
      preferencias.ultimoBackup = DateTime.now();
      await _storage!.setString(_automaticBackupKey, conteudo);
      await _storage!.setString(_stateKey, gerarBackup());
    }
  }
}
