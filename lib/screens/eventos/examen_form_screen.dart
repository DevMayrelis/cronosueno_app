// lib/screens/events/examen_form_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../onboarding/plan_creado_screen.dart';
import '../../services/evento_manager.dart';
import '../../models/evento_academico.dart';

class ExamenFormScreen extends StatefulWidget {
  final VoidCallback? onEventoGuardado;

  const ExamenFormScreen({super.key, this.onEventoGuardado});

  @override
  State<ExamenFormScreen> createState() => _ExamenFormScreenState();
}

class _ExamenFormScreenState extends State<ExamenFormScreen> {
  final TextEditingController _materiaController = TextEditingController();
  final TextEditingController _tipoExamenController = TextEditingController();
  final TextEditingController _temasController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _recordatorioActivo = true;
  int _diasRecordatorio = 1;
  bool _guardando = false;

  @override
  void dispose() {
    _materiaController.dispose();
    _tipoExamenController.dispose();
    _temasController.dispose();
    _lugarController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (!mounted) return;

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted) return;

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _guardarExamen() async {
    if (_guardando) return;

    if (_materiaController.text.isEmpty ||
        _tipoExamenController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      _mostrarSnackBar('Completa todos los campos obligatorios');
      return;
    }

    setState(() => _guardando = true);

    try {
      // Crear objeto EventoAcademico
      final fechaCompleta = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final evento = EventoAcademico(
        tipo: 'Examen',
        titulo: _tipoExamenController.text,
        descripcion: _temasController.text.isNotEmpty
            ? 'Temas: ${_temasController.text}'
            : 'Examen de ${_materiaController.text}',
        fecha: fechaCompleta,
        materia: _materiaController.text,
        lugar: _lugarController.text.isNotEmpty ? _lugarController.text : null,
        recordatorioActivo: _recordatorioActivo,
        diasRecordatorio: _diasRecordatorio,
      );

      // Guardar en Firebase usando EventoManager
      await context.read<EventoManager>().agregarEvento(evento);

      // Llamar al callback para incrementar el contador
      widget.onEventoGuardado?.call();

      final fechaFormateada =
          DateFormat('d \'de\' MMMM', 'es').format(fechaCompleta);
      final horaFormateada = DateFormat('HH:mm').format(fechaCompleta);

      // DESCRIPCIÓN MEJORADA DEL EVENTO
      final descripcionEvento = '${evento.titulo} - ${evento.materia}\n'
          '$fechaFormateada a las $horaFormateada\n'
          '${_temasController.text.isNotEmpty ? 'Temas: ${_temasController.text}\n' : ''}'
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
      _mostrarSnackBar('Error al guardar el examen: $e');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
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
          'Crear Examen',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Examen',
              style:
                  GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _materiaController,
                      label: 'Materia *',
                      hintText: 'Ej: Matemáticas, Física',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _tipoExamenController,
                      label: 'Tipo de examen *',
                      hintText: 'Ej: Parcial, Final, Quiz',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _temasController,
                      label: 'Temas a evaluar',
                      hintText: 'Ej: Derivadas, Integrales',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _lugarController,
                      label: 'Lugar (opcional)',
                      hintText: 'Ej: Aula 301, Laboratorio',
                    ),
                    const SizedBox(height: 20),
                    _buildDateSelector(),
                    const Divider(),
                    _buildTimeSelector(),
                    const Divider(),
                    _buildRecordatorioSettings(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSaveButton(),
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
        _selectedDate == null
            ? 'Seleccionar fecha *'
            : DateFormat('EEEE d MMMM', 'es').format(_selectedDate!),
        style: GoogleFonts.inter(
          color: _selectedDate == null ? Colors.grey : Colors.black,
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
        _selectedTime == null
            ? 'Seleccionar hora *'
            : _selectedTime!.format(context),
        style: GoogleFonts.inter(
          color: _selectedTime == null ? Colors.grey : Colors.black,
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
            'Recibir notificación antes del examen',
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _guardando ? null : _guardarExamen,
        style: FilledButton.styleFrom(
          backgroundColor: _guardando ? Colors.grey : const Color(0xFF5F63E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _guardando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'GUARDAR EXAMEN',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
