var _sequencia = 0;

String gerarId() => '${DateTime.now().microsecondsSinceEpoch}-${_sequencia++}';
