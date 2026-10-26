import 'dart:typed_data';

import 'package:flutter/material.dart';

class FotoContato extends StatelessWidget {
  final Uint8List? foto;
  final double raio;

  const FotoContato({super.key, this.foto, this.raio = 50});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: raio,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      backgroundImage: foto == null ? null : MemoryImage(foto!),
      child: foto == null
          ? Icon(Icons.person, size: raio, color: Colors.white)
          : null,
    );
  }
}
