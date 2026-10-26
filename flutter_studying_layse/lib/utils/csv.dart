List<List<String>> lerCsv(String texto) {
  final linhas = <List<String>>[];
  var linha = <String>[];
  var campo = StringBuffer();
  var entreAspas = false;
  for (var i = 0; i < texto.length; i++) {
    final caractere = texto[i];
    if (caractere == '"') {
      if (entreAspas && i + 1 < texto.length && texto[i + 1] == '"') {
        campo.write('"');
        i++;
      } else {
        entreAspas = !entreAspas;
      }
    } else if ((caractere == ',' || caractere == ';') && !entreAspas) {
      linha.add(campo.toString());
      campo = StringBuffer();
    } else if ((caractere == '\n' || caractere == '\r') && !entreAspas) {
      if (caractere == '\r' && i + 1 < texto.length && texto[i + 1] == '\n') {
        i++;
      }
      linha.add(campo.toString());
      campo = StringBuffer();
      if (linha.any((valor) => valor.trim().isNotEmpty)) linhas.add(linha);
      linha = <String>[];
    } else {
      campo.write(caractere);
    }
  }
  linha.add(campo.toString());
  if (linha.any((valor) => valor.trim().isNotEmpty)) linhas.add(linha);
  return linhas;
}

String gerarCsv(List<List<String>> linhas) {
  return linhas
      .map((linha) {
        return linha
            .map((campo) {
              final protegido = campo.replaceAll('"', '""');
              return '"$protegido"';
            })
            .join(',');
      })
      .join('\r\n');
}
