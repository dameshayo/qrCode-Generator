import 'package:flutter/material.dart';
import 'package:qr_code_app/model/history.dart';
import 'package:qr_code_app/screens/root.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HistoryStore().load();
  runApp(const QRGeneratorApp());
}

class QRGeneratorApp extends StatelessWidget {
  const QRGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4), brightness: Brightness.light),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4), brightness: Brightness.dark),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const RootPage(),
    );
  }
}
