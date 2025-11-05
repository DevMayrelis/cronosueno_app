// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/bienvenida_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CONFIGURACIÓN FIREBASE WEB - CON TUS DATOS REALES
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCQXCbtb1fQDwIt3fJ-UlZyiE2PDfkHfgM",
      authDomain: "app-cronosueno.firebaseapp.com",
      projectId: "app-cronosueno",
      storageBucket: "app-cronosueno.firebasestorage.app",
      messagingSenderId: "111910803255",
      appId: "1:111910803255:web:4f4ebaa20efff777326cb2",
      // measurementId no es necesario para Flutter
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CronoSueño',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BienvenidaScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
