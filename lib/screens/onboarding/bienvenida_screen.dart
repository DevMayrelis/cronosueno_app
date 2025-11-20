// lib/screens/bienvenida_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // IMPORT PANTALLA DE LOGIN

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xEC5F63E1),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/images/imagen_circular_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'CronoSueño',
                style: GoogleFonts.inter(
                  color: const Color(0xFFEBF0F4),
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ), // Text

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Descansa mejor, rinde más',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFEDF0F2),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegación a login
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F63E1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('COMENZAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
