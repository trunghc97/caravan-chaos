import 'package:flutter/material.dart';

import 'screens/start_game_page.dart';

void main() {
  runApp(const CaravanChaosApp());
}

class CaravanChaosApp extends StatelessWidget {
  const CaravanChaosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caravan Chaos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C5C)),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const StartGamePage(),
    );
  }
}
