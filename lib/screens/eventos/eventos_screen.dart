// lib/screens/events/eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'evento_form_screen.dart' as evento_form;
import 'examen_form_screen.dart' as examen_form;
import 'entrega_form_screen.dart' as entrega_form;
import 'eventos_list_screen.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  int _eventosAgregados = 0;

  void _incrementarEventos() {
    setState(() {
      _eventosAgregados++;
    });
  }

  // MÉTODO PARA MOSTRAR CONFIRMACIÓN ANTES DE AGREGAR
  void _mostrarConfirmacionAgregar(String tipoEvento, Widget pantallaDestino) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Agregar $tipoEvento',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres agregar un $tipoEvento?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              // Incrementar contador cuando se confirma
              _incrementarEventos();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => pantallaDestino,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F63E1),
            ),
            child: Text(
              'Continuar',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // TÍTULO Y DESCRIPCIÓN - CENTRADOS
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // LISTA DE EVENTOS CON SCROLL
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight -
                              250, // Espacio para header y footer
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildEventList(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // PIE DE PÁGINA (VOLVER, CONTADOR Y GESTIONAR EVENTOS)
                  _buildFooter(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Tipos de eventos',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona qué tipos de eventos académicos quieres agregar',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14, // Reducido ligeramente
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEventList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEventItem(
          context: context,
          icon: Icons.assignment_outlined,
          title: 'Exámenes',
          subtitle: 'Parciales, finales, quizzes.',
          onTap: () {
            _mostrarConfirmacionAgregar(
              'examen',
              examen_form.ExamenFormScreen(
                  onEventoGuardado: _incrementarEventos),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildEventItem(
          context: context,
          icon: Icons.assignment_turned_in_outlined,
          title: 'Entregas',
          subtitle: 'Proyectos, tareas, trabajos.',
          onTap: () {
            _mostrarConfirmacionAgregar(
              'entrega',
              entrega_form.EntregaFormScreen(
                  onEventoGuardado: _incrementarEventos),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildEventItem(
          context: context,
          icon: Icons.present_to_all_outlined,
          title: 'Presentaciones',
          subtitle: 'Exposiciones, defensas.',
          onTap: () {
            _mostrarConfirmacionAgregar(
              'presentación',
              evento_form.EventoFormScreen(
                  onEventoGuardado:
                      _incrementarEventos), // Agregar evento genérico
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // ÍCONO
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF5F63E1),
            ),
          ),

          const SizedBox(width: 12),

          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13, // Reducido ligeramente
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // BOTÓN AGREGAR - TAMAÑO RESPONSIVE
          SizedBox(
            width: 80, // Reducido ligeramente
            height: 32, // Reducido ligeramente
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F63E1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: Text(
                'Agregar',
                style: GoogleFonts.inter(
                  fontSize: 11, // Reducido ligeramente
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CONTADOR - SOLO SE MUESTRA SI HAY EVENTOS
          if (_eventosAgregados > 0) ...[
            Text(
              'Eventos agregados: $_eventosAgregados',
              style: GoogleFonts.inter(
                fontSize: 14, // Reducido ligeramente
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // DIVIDER
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),

          const SizedBox(height: 12),

          // BOTÓN GESTIONAR EVENTOS
          SizedBox(
            width: double.infinity,
            height: 48, // Reducido ligeramente
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EventosListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F63E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Gestionar Eventos',
                style: GoogleFonts.inter(
                  fontSize: 15, // Reducido ligeramente
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // BOTÓN VOLVER
          SizedBox(
            width: double.infinity,
            height: 48, // Reducido ligeramente
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5F63E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Volver',
                style: GoogleFonts.inter(
                  fontSize: 15, // Reducido ligeramente
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5F63E1),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // MARCA
          Center(
            child: Text(
              'CronoSueño',
              style: GoogleFonts.inter(
                fontSize: 12, // Reducido ligeramente
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),

          const SizedBox(height: 8), // Espacio extra de seguridad
        ],
      ),
    );
  }
}
