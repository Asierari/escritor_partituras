import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/metronome_provider.dart';
import 'pages/metronome_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MetronomeProvider()..init(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Escritor de Partituras',
      theme: ThemeData(
        useMaterial3: true, // 👈 CLAVE
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MetronomePage(),
    );
  }
}
