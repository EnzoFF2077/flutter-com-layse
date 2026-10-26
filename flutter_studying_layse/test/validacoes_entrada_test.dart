import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_studying_layse/utils/validacoes_entrada.dart';

void main() {
  test('aceita textos com acentos, espaços, hífen e apóstrofo', () {
    expect(validarSomenteTexto("Maria da Conceição-Silva", 'o nome'), isNull);
    expect(validarSomenteTexto("D'Ávila", 'a cidade'), isNull);
  });

  test('rejeita números em campos somente texto', () {
    expect(
      validarSomenteTexto('Maria 2', 'o nome'),
      'o nome deve conter somente letras.',
    );
  });

  test('permite campo opcional vazio', () {
    expect(validarSomenteTexto('', 'a cidade'), isNull);
  });
}
