// lib/screens/onboarding/plan_creado_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../eventos/eventos_screen.dart';

class PlanCreadoScreen extends StatelessWidget {
  final String evento;

  const PlanCreadoScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BOTÓN VOLVER
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 20),

              // CONTENIDO PRINCIPAL
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ÍCONO DE CONFIRMACIÓN
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 40,
                          color: Color(0xFF5F63E1),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TÍTULO
                      Text(
                        '¡Evento Creado!',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // DESCRIPCIÓN
                      Text(
                        'Tu evento ha sido guardado exitosamente',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // EVENTO RECIÉN CREADO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evento guardado:',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              evento,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF1E293B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // RECOMENDACIONES
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE0F2FE),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recomendaciones',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRecomendacionItem(
                                'Alertas de sueño activadas'),
                            _buildRecomendacionItem(
                                'Recordatorios programados'),
                            _buildRecomendacionItem(
                                'Revisa tu planificación regularmente'),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height: 32), // Espacio extra antes del botón
                    ],
                  ),
                ),
              ),

              // BOTÓN CONTINUAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const EventosScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F63E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8), // Pequeño espacio después del botón
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecomendacionItem(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: Color(0xFF5F63E1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
