// lib/screens/events/editar_evento_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/evento_manager.dart';
import '../../models/evento_academico.dart';
import '../onboarding/plan_creado_screen.dart';

class EditarEventoScreen extends StatefulWidget {
  final EventoAcademico evento;

  const EditarEventoScreen({super.key, required this.evento});

  @override
  State<EditarEventoScreen> createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _materiaController;
  late TextEditingController _descripcionController;
  late TextEditingController _lugarController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _recordatorioActivo;
  late int _diasRecordatorio;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con los datos del evento
    _tituloController = TextEditingController(text: widget.evento.titulo);
    _materiaController = TextEditingController(text: widget.evento.materia);
    _descripcionController =
        TextEditingController(text: widget.evento.descripcion);
    _lugarController = TextEditingController(text: widget.evento.lugar ?? '');

    // Inicializar fecha y hora
    _selectedDate = widget.evento.fecha;
    _selectedTime = TimeOfDay.fromDateTime(widget.evento.fecha);
    _recordatorioActivo = widget.evento.recordatorioActivo;
    _diasRecordatorio = widget.evento.diasRecordatorio;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _materiaController.dispose();
    _descripcionController.dispose();
    _lugarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _actualizarEvento() async {
    if (_tituloController.text.isEmpty || _materiaController.text.isEmpty) {
      _mostrarSnackBar('Completa todos los campos obligatorios');
      return;
    }

    // Crear fecha combinada
    final fechaCompleta = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Crear evento actualizado usando copyWith
    final eventoActualizado = widget.evento.copyWith(
      titulo: _tituloController.text,
      materia: _materiaController.text,
      descripcion: _descripcionController.text,
      fecha: fechaCompleta,
      lugar: _lugarController.text.isNotEmpty ? _lugarController.text : null,
      recordatorioActivo: _recordatorioActivo,
      diasRecordatorio: _diasRecordatorio,
    );

    try {
      // Actualizar en Firebase usando EventoManager
      await context.read<EventoManager>().actualizarEvento(eventoActualizado);

      final fechaFormateada =
          DateFormat('d \'de\' MMMM', 'es').format(fechaCompleta);
      final horaFormateada = DateFormat('HH:mm').format(fechaCompleta);

      // Descripción del evento actualizado
      final descripcionEvento =
          '${eventoActualizado.titulo} - ${eventoActualizado.materia}\n'
          '$fechaFormateada a las $horaFormateada\n'
          '${_descripcionController.text.isNotEmpty ? '${_descripcionController.text}\n' : ''}'
          '${_lugarController.text.isNotEmpty ? _lugarController.text : "Lugar por definir"}';

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlanCreadoScreen(
            evento: descripcionEvento,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarSnackBar('Error al actualizar el evento: $e');
    }
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
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
          'Editar ${widget.evento.tipo}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false, // Important: set bottom to false
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar ${widget.evento.tipo}',
                      style: GoogleFonts.inter(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: _tituloController,
                              label: 'Título del evento *',
                              hintText:
                                  'Ej: Presentación final, Defensa de tesis',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _materiaController,
                              label: 'Materia/Área *',
                              hintText: 'Ej: Comunicación, Investigación',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _descripcionController,
                              label: 'Descripción',
                              hintText:
                                  'Ej: Presentación sobre temas investigados',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _lugarController,
                              label: 'Lugar (opcional)',
                              hintText: 'Ej: Aula 301, Auditorio principal',
                            ),
                            const SizedBox(height: 20),
                            _buildDateSelector(),
                            const Divider(),
                            _buildTimeSelector(),
                            const Divider(),
                            _buildRecordatorioSettings(),
                            const SizedBox(
                                height: 80), // Espacio extra para el botón fijo
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botón fijo en la parte inferior
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: _buildUpdateButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5F63E1), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return ListTile(
      onTap: _selectDate,
      leading: const Icon(Icons.calendar_today, color: Color(0xFF5F63E1)),
      title: Text(
        DateFormat('EEEE d MMMM', 'es').format(_selectedDate),
        style: GoogleFonts.inter(
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildTimeSelector() {
    return ListTile(
      onTap: _selectTime,
      leading: const Icon(Icons.access_time, color: Color(0xFF5F63E1)),
      title: Text(
        _selectedTime.format(context),
        style: GoogleFonts.inter(
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildRecordatorioSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(
            'Activar recordatorio',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Recibir notificación antes del evento',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
          value: _recordatorioActivo,
          onChanged: (value) {
            setState(() => _recordatorioActivo = value);
          },
          activeTrackColor:
              const Color(0xFF5F63E1).withAlpha((0.5 * 255).round()),
          thumbColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF5F63E1);
              }
              return Colors.grey[300];
            },
          ),
        ),
        if (_recordatorioActivo) ...[
          const SizedBox(height: 10),
          Text(
            'Recordar:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _diasRecordatorio,
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 día antes')),
              DropdownMenuItem(value: 2, child: Text('2 días antes')),
              DropdownMenuItem(value: 3, child: Text('3 días antes')),
              DropdownMenuItem(value: 7, child: Text('1 semana antes')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _diasRecordatorio = value);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _actualizarEvento,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF5F63E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'ACTUALIZAR EVENTO',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
