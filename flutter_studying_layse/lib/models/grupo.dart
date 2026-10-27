import '../utils/ids.dart';

class Grupo {
  String id;
  String nome;
  List<String> membros;

  Grupo({String? id, required this.nome, List<String>? membros})
    : id = id ?? gerarId(),
      membros = membros ?? [];

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'membros': membros};

  factory Grupo.fromJson(Map<String, dynamic> json) => Grupo(
    id: json['id']?.toString(),
    nome: json['nome']?.toString() ?? '',
    membros: List<String>.from(json['membros'] ?? const []),
  );
}
