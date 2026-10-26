import 'package:flutter/material.dart';

class Preferencias {
  ThemeMode tema;
  bool backupAutomatico;
  bool exibirFotos;
  int diasLembrete;
  String ordenacao;
  DateTime? ultimoBackup;

  Preferencias({
    this.tema = ThemeMode.system,
    this.backupAutomatico = false,
    this.exibirFotos = true,
    this.diasLembrete = 7,
    this.ordenacao = 'nome',
    this.ultimoBackup,
  });

  Map<String, dynamic> toJson() => {
    'tema': tema.name,
    'backupAutomatico': backupAutomatico,
    'exibirFotos': exibirFotos,
    'diasLembrete': diasLembrete,
    'ordenacao': ordenacao,
    'ultimoBackup': ultimoBackup?.toIso8601String(),
  };

  factory Preferencias.fromJson(Map<String, dynamic> json) => Preferencias(
    tema: ThemeMode.values.firstWhere(
      (tema) => tema.name == json['tema'],
      orElse: () => ThemeMode.system,
    ),
    backupAutomatico: json['backupAutomatico'] == true,
    exibirFotos: json['exibirFotos'] != false,
    diasLembrete: int.tryParse(json['diasLembrete']?.toString() ?? '') ?? 7,
    ordenacao: json['ordenacao']?.toString() ?? 'nome',
    ultimoBackup: DateTime.tryParse(json['ultimoBackup']?.toString() ?? ''),
  );
}
