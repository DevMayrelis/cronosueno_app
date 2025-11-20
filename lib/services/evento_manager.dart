// lib/services/evento_manager.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Importación faltante para StreamSubscription
import 'evento_service.dart';
import '../models/evento_academico.dart'; // Corregí el nombre del archivo

/// Gestor de estado para los eventos académicos
/// Combina Provider para gestión de estado con Streams para sincronización en tiempo real
class EventoManager with ChangeNotifier {
  // Cambié a PascalCase
  final EventoService _eventoService = EventoService();
  List<EventoAcademico> _eventos = []; // Corregí el nombre de la variable
  StreamSubscription? _eventosSubscription; // Suscripción al stream de eventos

  // =============================================
  // PROPIEDADES PÚBLICAS
  // =============================================

  /// Lista de todos los eventos académicos del usuario
  List<EventoAcademico> get eventos => _eventos;

  /// Stream de eventos en tiempo real para usar directamente con StreamBuilder
  Stream<List<EventoAcademico>> get eventosStream =>
      _eventoService.obtenerEventosStream();

  /// Stream de próximos eventos para widgets específicos
  Stream<List<EventoAcademico>> get proximosEventosStream =>
      _eventoService.obtenerProximosEventosStream(limite: 5);

  // =============================================
  // CONSTRUCTOR Y DISPOSE
  // =============================================

  EventoManager() {
    _iniciarEscuchaEnTiempoReal(); // Iniciar sincronización automática al crear
  }

  @override
  void dispose() {
    _cancelarEscuchaEnTiempoReal(); // Limpiar recursos al destruir
    super.dispose();
  }

  // =============================================
  // MÉTODOS DE SINCRONIZACIÓN EN TIEMPO REAL
  // =============================================

  /// Inicia la escucha en tiempo real de los eventos desde Firebase
  /// Los cambios se reflejan automáticamente en la lista _eventos
  void _iniciarEscuchaEnTiempoReal() {
    _eventosSubscription = _eventoService.obtenerEventosStream().listen(
      (nuevosEventos) {
        _eventos = nuevosEventos;
        notifyListeners(); // Notificar a todos los widgets escuchando
        print(
            'EventoManager: Lista actualizada con ${_eventos.length} eventos');
      },
      onError: (error) {
        print('EventoManager: Error en stream de eventos: $error');
      },
    );
  }

  /// Cancela la suscripción al stream para liberar recursos
  void _cancelarEscuchaEnTiempoReal() {
    _eventosSubscription?.cancel();
    _eventosSubscription = null;
    print('EventoManager: Escucha en tiempo real cancelada');
  }

  // =============================================
  // MÉTODOS CRUD (OPERACIONES DE ESCRITURA)
  // =============================================

  /// Agrega un nuevo evento académico a Firebase
  /// [evento]: El evento a crear (sin ID)
  /// Retorna: Future que completa cuando se guarda el evento
  Future<void> agregarEvento(EventoAcademico evento) async {
    try {
      print('📝 EventoManager: Agregando evento: ${evento.titulo}');
      await _eventoService.guardarEvento(evento);
      // NO llamamos cargarEventos() porque el stream se actualiza automáticamente
      print('✅ EventoManager: Evento agregado exitosamente');
    } catch (e) {
      print('❌ EventoManager: Error al agregar evento: $e');
      rethrow; // Relanzar el error para manejo en UI
    }
  }

  /// Elimina un evento académico de Firebase
  /// [id]: El ID del evento a eliminar
  /// Retorna: Future que completa cuando se elimina el evento
  Future<void> eliminarEvento(String id) async {
    try {
      print('EventoManager: Eliminando evento ID: $id');
      await _eventoService.eliminarEvento(id);
      // NO llamamos cargarEventos() porque el stream se actualiza automáticamente
      print('EventoManager: Evento eliminado exitosamente');
    } catch (e) {
      print('EventoManager: Error al eliminar evento: $e');
      rethrow; // Relanzar el error para manejo en UI
    }
  }

  /// Actualiza un evento académico existente en Firebase
  /// [evento]: El evento con los datos actualizados (debe tener ID)
  /// Retorna: Future que completa cuando se actualiza el evento
  Future<void> actualizarEvento(EventoAcademico evento) async {
    try {
      if (evento.id == null) {
        throw Exception('No se puede actualizar un evento sin ID');
      }

      print('✏️ EventoManager: Actualizando evento ID: ${evento.id}');
      await _eventoService.actualizarEvento(evento);
      // NO llamamos cargarEventos() porque el stream se actualiza automáticamente
      print('EventoManager: Evento actualizado exitosamente');
    } catch (e) {
      print('EventoManager: Error al actualizar evento: $e');
      rethrow; // Relanzar el error para manejo en UI
    }
  }

  // =============================================
  // MÉTODOS DE LECTURA (OPERACIONES PUNTUALES)
  // =============================================

  /// Carga los eventos una vez (método tradicional)
  /// Útil para operaciones que no requieren sincronización en tiempo real
  /// Retorna: Future que completa cuando se cargan los eventos
  Future<void> cargarEventos() async {
    try {
      print('EventoManager: Cargando eventos (una vez)');
      _eventos = await _eventoService.obtenerEventos();
      notifyListeners();
      print('EventoManager: ${_eventos.length} eventos cargados');
    } catch (e) {
      print('EventoManager: Error al cargar eventos: $e');
      rethrow;
    }
  }

  /// Obtiene los próximos eventos (método tradicional, una sola vez)
  /// [limite]: Número máximo de eventos a retornar (por defecto 5)
  /// Retorna: Future con los próximos eventos
  Future<List<EventoAcademico>> obtenerProximosEventos({int limite = 5}) async {
    try {
      print('EventoManager: Obteniendo próximos eventos');
      return await _eventoService.obtenerProximosEventos(limite: limite);
    } catch (e) {
      print('EventoManager: Error al obtener próximos eventos: $e');
      return [];
    }
  }

  /// Cuenta el total de eventos del usuario
  /// Retorna: Future con el número total de eventos
  Future<int> contarEventos() async {
    try {
      return await _eventoService.contarEventos();
    } catch (e) {
      print('EventoManager: Error al contar eventos: $e');
      return 0;
    }
  }

  // =============================================
  // MÉTODOS DE BÚSQUEDA Y FILTRADO
  // =============================================

  /// Filtra eventos por tipo (Examen, Entrega, Evento)
  /// [tipo]: El tipo de evento a filtrar
  /// Retorna: Lista de eventos del tipo especificado
  List<EventoAcademico> eventosPorTipo(String tipo) {
    return _eventos.where((evento) => evento.tipo == tipo).toList();
  }

  /// Filtra eventos por materia
  /// [materia]: La materia a filtrar
  /// Retorna: Lista de eventos de la materia especificada
  List<EventoAcademico> eventosPorMateria(String materia) {
    return _eventos.where((evento) => evento.materia == materia).toList();
  }

  /// Obtiene eventos para una fecha específica
  /// [fecha]: La fecha para filtrar eventos
  /// Retorna: Lista de eventos en la fecha especificada
  List<EventoAcademico> eventosPorFecha(DateTime fecha) {
    return _eventos.where((evento) {
      return evento.fecha.year == fecha.year &&
          evento.fecha.month == fecha.month &&
          evento.fecha.day == fecha.day;
    }).toList();
  }

  /// Obtiene eventos próximos (a partir de hoy)
  /// [dias]: Número de días hacia adelante para buscar (opcional)
  /// Retorna: Lista de eventos futuros
  List<EventoAcademico> obtenerEventosProximos({int? dias}) {
    final ahora = DateTime.now();
    final fechaLimite = dias != null
        ? ahora.add(Duration(days: dias))
        : DateTime(ahora.year + 1); // Un año por defecto

    return _eventos.where((evento) {
      return evento.fecha.isAfter(ahora) && evento.fecha.isBefore(fechaLimite);
    }).toList();
  }
}
