// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding/bienvenida_screen.dart';
import 'services/evento_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZAR FORMATO DE FECHAS EN ESPAÑOL
  await initializeDateFormatting('es');

  // INICIALIZAR GOOGLE FONTS
  await GoogleFonts.pendingFonts([
    GoogleFonts.getFont('Inter'),
  ]);

  // CONFIGURACIÓN FIREBASE WEB - CON TUS DATOS REALES
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCQXCbtb1fQDwIt3fJ-UlZyiE2PDfkHfgM",
      authDomain: "app-cronosueno.firebaseapp.com",
      projectId: "app-cronosueno",
      storageBucket: "app-cronosueno.firebasestorage.app",
      messagingSenderId: "111910803255",
      appId: "1:111910803255:web:4f4ebaa20efff777326cb2",
    ),
  );

  // CONFIGURACIÓN ESPECÍFICA PARA WEB - ELIMINAR BARRAS DEL SISTEMA
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // Solo mantener barra de estado superior
  );

  // Configurar colores de las barras del sistema
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventoManager()),
      ],
      child: MaterialApp(
        title: 'CronoSueño',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5F63E1),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            titleTextStyle: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            // Configuración específica para la barra de estado
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
        locale: const Locale('es'),
        home: const BienvenidaScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
