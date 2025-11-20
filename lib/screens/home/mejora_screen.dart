// lib/screens/onboarding/mejora_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../eventos/eventos_screen.dart'; // Import del siguiente paso en el flujo

/// Pantalla de selección de objetivos de mejora para el usuario
/// Es parte del proceso de onboarding después del registro
class MejoraScreen extends StatelessWidget {
  const MejoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // INDICADOR DE PROGRESO (Toggle visual)
              _buildProgressIndicator(),

              const SizedBox(height: 40),

              // IMAGEN ILUSTRATIVA
              _buildIllustration(),

              const SizedBox(height: 40),

              // TÍTULO Y DESCRIPCIÓN
              _buildHeader(),

              const SizedBox(height: 40),

              // OPCIONES DE MEJORA
              _buildOptions(context),

              const Spacer(),

              // BOTÓN CONTINUAR
              _buildContinueButton(),

              const SizedBox(height: 20),

              // MARCA DE LA APP
              _buildAppBrand(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget del indicador de progreso en el onboarding
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF5F63E1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget de la imagen ilustrativa
  Widget _buildIllustration() {
    return Image.asset(
      'assets/images/mejora_graph.png',
      height: 180,
      errorBuilder: (context, error, stackTrace) {
        // Fallback si la imagen no carga
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.insights, size: 80, color: Color(0xFF5F63E1)),
        );
      },
    );
  }

  /// Widget del encabezado con título y descripción
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          '¿Qué quieres mejorar?',
          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona todos los que apliquen',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Widget de las opciones de mejora seleccionables
  Widget _buildOptions(BuildContext context) {
    return Column(
      children: [
        _buildOption(
          icon: Icons.school,
          text: 'Rendimiento académico',
          onTap: () {
            // Navegar a la pantalla de tipos de eventos
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EventosScreen()),
            );
          },
        ),
        _buildOption(
          icon: Icons.psychology,
          text: 'Reducir estrés',
          onTap: () {
            // Implementar funcionalidad para reducir estrés
            _mostrarMensajeProximamente(context);
          },
        ),
        _buildOption(
          icon: Icons.access_time,
          text: 'Regular horarios',
          onTap: () {
            // Implementar funcionalidad para regular horarios
            _mostrarMensajeProximamente(context);
          },
        ),
      ],
    );
  }

  /// Widget individual de cada opción de mejora
  Widget _buildOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF5F63E1), size: 28),
              const SizedBox(width: 16),
              Text(
                text,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget del botón continuar (actualmente deshabilitado)
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: null, // Deshabilitado por ahora
        style: FilledButton.styleFrom(
          backgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Continuar',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Widget de la marca de la aplicación
  Widget _buildAppBrand() {
    return Text(
      'CronoSueño',
      style: GoogleFonts.inter(color: Colors.grey),
    );
  }

  /// Muestra un mensaje temporal para funcionalidades en desarrollo
  void _mostrarMensajeProximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
