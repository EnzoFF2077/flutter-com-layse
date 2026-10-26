String normalizar(String texto) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const semAcento = 'aaaaaeeeeiiiiooooouuuuc';
  var resultado = texto.toLowerCase();
  for (var i = 0; i < comAcento.length; i++) {
    resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
  }
  return resultado;
}

String formatarData(DateTime? data) {
  if (data == null) return 'Não informada';
  return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
}

DateTime? lerData(String valor) {
  final texto = valor.trim();
  if (texto.isEmpty) return null;
  final iso = DateTime.tryParse(texto);
  if (iso != null) return iso;
  final partes = texto.split(RegExp(r'[/\-.]'));
  if (partes.length != 3) return null;
  final primeiro = int.tryParse(partes[0]);
  final segundo = int.tryParse(partes[1]);
  final terceiro = int.tryParse(partes[2]);
  if (primeiro == null || segundo == null || terceiro == null) return null;
  try {
    final data = primeiro > 31
        ? DateTime(primeiro, segundo, terceiro)
        : DateTime(terceiro, segundo, primeiro);
    if (data.day == (primeiro > 31 ? terceiro : primeiro) &&
        data.month == segundo) {
      return data;
    }
  } catch (_) {}
  return null;
}

int diasAteProximoAniversario(DateTime nascimento, DateTime agora) {
  var aniversario = DateTime(agora.year, nascimento.month, nascimento.day);
  final hoje = DateTime(agora.year, agora.month, agora.day);
  if (aniversario.isBefore(hoje)) {
    aniversario = DateTime(agora.year + 1, nascimento.month, nascimento.day);
  }
  return aniversario.difference(hoje).inDays;
}
