import 'package:flutter/material.dart';

import 'data/app_scope.dart';
import 'data/app_store.dart';
import 'screens/aniversarios_screen.dart';
import 'screens/arquivos_screen.dart';
import 'screens/categorias_screen.dart';
import 'screens/configuracoes_screen.dart';
import 'screens/contatos_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/grupos_screen.dart';
import 'screens/pesquisa_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final store = AppStore();
  late final Future<void> carregamento;

  @override
  void initState() {
    super.initState();
    carregamento = store.carregar();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: carregamento,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return AppScope(
          store: store,
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              return MaterialApp(
                title: 'Agenda de Contatos',
                debugShowCheckedModeBanner: false,
                themeMode: store.preferencias.tema,
                theme: _tema(Brightness.light),
                darkTheme: _tema(Brightness.dark),
                initialRoute: '/',
                routes: {
                  '/': (context) => const TelaListagem(),
                  '/favoritos': (context) => const TelaFavoritos(),
                  '/categorias': (context) => const TelaCategorias(),
                  '/grupos': (context) => const TelaGrupos(),
                  '/aniversarios': (context) => const TelaAniversarios(),
                  '/pesquisa': (context) => const TelaPesquisaAvancada(),
                  '/arquivos': (context) => const TelaArquivos(),
                  '/configuracoes': (context) => const TelaConfiguracoes(),
                },
              );
            },
          ),
        );
      },
    );
  }

  ThemeData _tema(Brightness brilho) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB93329),
      brightness: brilho,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
    );
  }
}
