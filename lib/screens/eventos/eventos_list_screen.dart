// lib/screens/events/eventos_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/evento_manager.dart';
import '../../models/evento_academico.dart';
import 'editar_evento_screen.dart';
import 'editar_examen_screen.dart';

class EventosListScreen extends StatefulWidget {
  const EventosListScreen({super.key});

  @override
  State<EventosListScreen> createState() => _EventosListScreenState();
}

class _EventosListScreenState extends State<EventosListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar eventos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventoManager>().cargarEventos();
      }
    });
  }

  // Obtener eventos del EventoManager
  List<EventoAcademico> get _eventos => context.watch<EventoManager>().eventos;

  void _editarEvento(EventoAcademico evento) {
    // Navegar a la pantalla de edición correspondiente según el tipo
    switch (evento.tipo) {
      case 'Examen':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditarExamenScreen(evento: evento),
          ),
        );
        break;
      case 'Entrega':
      case 'Presentación':
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditarEventoScreen(evento: evento),
          ),
        );
    }
  }

  void _eliminarEvento(EventoAcademico evento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Evento',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${evento.titulo}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo primero
              if (evento.id != null) {
                await context.read<EventoManager>().eliminarEvento(evento.id!);
                if (mounted) {
                  _mostrarSnackBar('Evento eliminado correctamente');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text(
              'Eliminar',
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

  void _mostrarSnackBar(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _mostrarDetallesEvento(EventoAcademico evento) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // IMPORTANTE: Permitir scroll
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7, // Tamaño inicial (70% de la pantalla)
        minChildSize: 0.5, // Tamaño mínimo (50% de la pantalla)
        maxChildSize: 0.9, // Tamaño máximo (90% de la pantalla)
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          evento.icon,
                          size: 22,
                          color: evento.colorIcon,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          evento.titulo,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetalleItem('Tipo', evento.tipo),
                  _buildDetalleItem('Materia', evento.materia),
                  _buildDetalleItem('Fecha', evento.fechaFormateada),
                  _buildDetalleItem('Hora', evento.horaFormateada(context)),
                  if (evento.descripcion.isNotEmpty)
                    _buildDetalleItem('Descripción', evento.descripcion),
                  if (evento.lugar != null && evento.lugar!.isNotEmpty)
                    _buildDetalleItem('Lugar', evento.lugar!),
                  _buildDetalleItem(
                    'Recordatorio',
                    evento.recordatorioActivo
                        ? '${evento.diasRecordatorio} día(s) antes'
                        : 'Desactivado',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _editarEvento(evento);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5F63E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Editar',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5F63E1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _eliminarEvento(evento);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Eliminar',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1E293B),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mis Eventos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Eventos',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca un evento para ver detalles, editar o eliminar',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // CONTADOR DE EVENTOS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0F2FE),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: const Color(0xFF5F63E1),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Eventos programados: ${_eventos.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // LISTA DE EVENTOS
            Expanded(
              child: _eventos.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: _eventos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final evento = _eventos[index];
                        return _buildEventoItem(evento, context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventoItem(EventoAcademico evento, BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarDetallesEvento(evento),
      child: Container(
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
                evento.icon,
                size: 22,
                color: evento.colorIcon,
              ),
            ),
            const SizedBox(width: 16),
            // INFORMACIÓN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${evento.tipo} - ${evento.materia}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        evento.fechaFormateada,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        evento.horaFormateada(context),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // BOTÓN DE ACCIÓN
            IconButton(
              onPressed: () => _mostrarDetallesEvento(evento),
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.event_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No hay eventos',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los eventos que crees aparecerán aquí',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
