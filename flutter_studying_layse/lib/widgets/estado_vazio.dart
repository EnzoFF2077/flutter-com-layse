import 'package:flutter/material.dart';

class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? descricao;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(titulo, textAlign: TextAlign.center),
            if (descricao != null) ...[
              const SizedBox(height: 8),
              Text(
                descricao!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
