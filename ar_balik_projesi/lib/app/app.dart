import 'package:flutter/material.dart';

import '../features/fish_catalog/presentation/pages/fish_catalog_page.dart';

class ArBalikApp extends StatelessWidget {
  const ArBalikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Balık Ansiklopedisi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const FishCatalogPage(),
    );
  }
}
