import 'package:flutter/services.dart';

final somenteTexto = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ\s'.-]")),
];

String? validarSomenteTexto(
  String? valor,
  String campo, {
  bool obrigatorio = false,
}) {
  final texto = valor?.trim() ?? '';
  if (obrigatorio && texto.isEmpty) return 'Informe $campo.';
  if (texto.isNotEmpty &&
      !RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ\s'.-]+$").hasMatch(texto)) {
    return '$campo deve conter somente letras.';
  }
  return null;
}
