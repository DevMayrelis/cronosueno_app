// lib/models/evento_academico.dart
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventoAcademico {
  final String? id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String tipo;
  final String materia;
  final String? lugar;
  final bool recordatorioActivo;
  final int diasRecordatorio;

  EventoAcademico({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.tipo,
    required this.materia,
    this.lugar,
    this.recordatorioActivo = true,
    this.diasRecordatorio = 1,
  });

  // Métodos para la UI
  String get fechaFormateada => DateFormat('d \'de\' MMMM', 'es').format(fecha);

  String horaFormateada(BuildContext context) =>
      DateFormat('HH:mm').format(fecha);

  IconData get icon {
    switch (tipo) {
      case 'Examen':
        return Icons.assignment_outlined;
      case 'Entrega':
        return Icons.assignment_turned_in_outlined;
      case 'Presentación':
        return Icons.present_to_all_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  Color get colorIcon => const Color(0xFF5F63E1);

  // Método para convertir a JSON para Firestore - CORREGIDO
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.millisecondsSinceEpoch, // Cambiado a milliseconds
      'tipo': tipo,
      'materia': materia,
      'lugar': lugar,
      'recordatorioActivo': recordatorioActivo,
      'diasRecordatorio': diasRecordatorio,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }

  // Método para crear desde Firestore - CORREGIDO
  factory EventoAcademico.fromFirestore(Map<String, dynamic> data, String id) {
    // Manejar diferentes formatos de fecha
    DateTime fecha;
    if (data['fecha'] is Timestamp) {
      fecha = (data['fecha'] as Timestamp).toDate();
    } else if (data['fecha'] is int) {
      fecha = DateTime.fromMillisecondsSinceEpoch(data['fecha']);
    } else {
      fecha = DateTime.now(); // Fallback
    }

    return EventoAcademico(
      id: id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fecha: fecha,
      tipo: data['tipo'] ?? 'Evento',
      materia: data['materia'] ?? '',
      lugar: data['lugar'],
      recordatorioActivo: data['recordatorioActivo'] ?? true,
      diasRecordatorio: data['diasRecordatorio'] ?? 1,
    );
  }

  // Método alternativo para crear desde Map
  factory EventoAcademico.fromMap(Map<String, dynamic> map) {
    return EventoAcademico(
      id: map['id'],
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      tipo: map['tipo'] ?? '',
      materia: map['materia'] ?? '',
      lugar: map['lugar'],
      recordatorioActivo: map['recordatorioActivo'] ?? true,
      diasRecordatorio: map['diasRecordatorio'] ?? 1,
    );
  }

  // Método para convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo,
      'materia': materia,
      'lugar': lugar,
      'recordatorioActivo': recordatorioActivo,
      'diasRecordatorio': diasRecordatorio,
    };
  }

  // Método para crear una copia del evento con nuevos valores
  EventoAcademico copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    String? tipo,
    String? materia,
    String? lugar,
    bool? recordatorioActivo,
    int? diasRecordatorio,
  }) {
    return EventoAcademico(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      materia: materia ?? this.materia,
      lugar: lugar ?? this.lugar,
      recordatorioActivo: recordatorioActivo ?? this.recordatorioActivo,
      diasRecordatorio: diasRecordatorio ?? this.diasRecordatorio,
    );
  }

  @override
  String toString() {
    return 'EventoAcademico(id: $id, titulo: $titulo, tipo: $tipo, materia: $materia, fecha: $fecha, lugar: $lugar, recordatorioActivo: $recordatorioActivo, diasRecordatorio: $diasRecordatorio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventoAcademico &&
        other.id == id &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.fecha == fecha &&
        other.tipo == tipo &&
        other.materia == materia &&
        other.lugar == lugar &&
        other.recordatorioActivo == recordatorioActivo &&
        other.diasRecordatorio == diasRecordatorio;
  }

  @override
  int get hashCode {
    return Object.hash(id, titulo, descripcion, fecha, tipo, materia, lugar,
        recordatorioActivo, diasRecordatorio);
  }
}
