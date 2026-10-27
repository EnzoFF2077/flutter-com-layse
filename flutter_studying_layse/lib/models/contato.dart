import 'dart:convert';
import 'dart:typed_data';

import '../utils/ids.dart';

class Contato {
  String id;
  String nome;
  String email;
  String telefone;
  String observacoes;
  String cidade;
  String empresa;
  DateTime? dataNascimento;
  DateTime dataCadastro;
  Uint8List? foto;
  bool favorito;
  List<String> categorias;

  Contato({
    String? id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.observacoes = '',
    this.cidade = '',
    this.empresa = '',
    this.dataNascimento,
    DateTime? dataCadastro,
    this.foto,
    this.favorito = false,
    List<String>? categorias,
  }) : id = id ?? gerarId(),
       dataCadastro = dataCadastro ?? DateTime.now(),
       categorias = categorias ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'telefone': telefone,
    'observacoes': observacoes,
    'cidade': cidade,
    'empresa': empresa,
    'dataNascimento': dataNascimento?.toIso8601String(),
    'dataCadastro': dataCadastro.toIso8601String(),
    'foto': foto == null ? null : base64Encode(foto!),
    'favorito': favorito,
    'categorias': categorias,
  };

  factory Contato.fromJson(Map<String, dynamic> json) => Contato(
    id: json['id']?.toString(),
    nome: json['nome']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    telefone: json['telefone']?.toString() ?? '',
    observacoes: json['observacoes']?.toString() ?? '',
    cidade: json['cidade']?.toString() ?? '',
    empresa: json['empresa']?.toString() ?? '',
    dataNascimento: DateTime.tryParse(json['dataNascimento']?.toString() ?? ''),
    dataCadastro:
        DateTime.tryParse(json['dataCadastro']?.toString() ?? '') ??
        DateTime.now(),
    foto: json['foto'] == null ? null : base64Decode(json['foto'].toString()),
    favorito: json['favorito'] == true,
    categorias: List<String>.from(json['categorias'] ?? const []),
  );
}
