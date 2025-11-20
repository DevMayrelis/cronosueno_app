// lib/services/evento_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/evento_academico.dart';

/// Servicio para manejar todas las operaciones CRUD de eventos académicos en Firebase
/// Ahora incluye soporte para streams en tiempo real
class EventoService {
  // Instancias de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene el ID del usuario actualmente autenticado
  String? get _userId => _auth.currentUser?.uid;

  // =============================================
  // MÉTODOS DE ESCRITURA (CRUD)
  // =============================================

  /// Guarda un nuevo evento académico en Firestore
  /// Retorna el ID del documento creado
  Future<String?> guardarEvento(EventoAcademico evento) async {
    try {
      // Verificar que hay un usuario autenticado
      if (_userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Referencia a la colección de eventos del usuario
      final eventosRef = _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos');

      // Convertir evento a Map y guardar en Firestore
      final docRef = await eventosRef.add(evento.toJson());

      print('Evento guardado exitosamente con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al guardar evento: $e');
      return null;
    }
  }

  /// Actualiza un evento existente en Firestore
  Future<bool> actualizarEvento(EventoAcademico evento) async {
    try {
      if (_userId == null || evento.id == null) {
        throw Exception('Usuario no autenticado o evento sin ID');
      }

      // Referencia al documento específico del evento
      final eventoRef = _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .doc(evento.id);

      // Actualizar el documento
      await eventoRef.update(evento.toJson());

      print('Evento actualizado exitosamente: ${evento.id}');
      return true;
    } catch (e) {
      print('Error al actualizar evento: $e');
      return false;
    }
  }

  /// Elimina un evento de Firestore
  Future<bool> eliminarEvento(String eventoId) async {
    try {
      if (_userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Referencia al documento del evento
      final eventoRef = _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .doc(eventoId);

      // Eliminar el documento
      await eventoRef.delete();

      print('Evento eliminado exitosamente: $eventoId');
      return true;
    } catch (e) {
      print('Error al eliminar evento: $e');
      return false;
    }
  }

  // =============================================
  // MÉTODOS DE LECTURA (STREAMS EN TIEMPO REAL)
  // =============================================

  /// Obtiene un stream de todos los eventos académicos del usuario actual
  /// Los eventos se ordenan por fecha (más cercanos primero)
  /// Este stream se actualiza automáticamente cuando hay cambios en Firestore
  Stream<List<EventoAcademico>> obtenerEventosStream() {
    try {
      if (_userId == null) {
        return Stream.value([]); // Retorna stream vacío si no hay usuario
      }

      return _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .orderBy('fecha', descending: false) // Más cercanos primero
          .snapshots() // Convierte a stream que escucha cambios en tiempo real
          .map((querySnapshot) {
        // Convierte cada QuerySnapshot a lista de EventoAcademico
        final eventos = querySnapshot.docs.map((doc) {
          return EventoAcademico.fromFirestore(doc.data(), doc.id);
        }).toList();

        print('Stream actualizado: ${eventos.length} eventos');
        return eventos;
      });
    } catch (e) {
      print('Error en obtenerEventosStream: $e');
      return Stream.value([]);
    }
  }

  /// Obtiene todos los eventos académicos del usuario actual (método tradicional)
  /// Útil para operaciones que solo necesitan los datos una vez
  Future<List<EventoAcademico>> obtenerEventos() async {
    try {
      if (_userId == null) {
        return [];
      }

      // Consulta a Firestore ordenada por fecha (más recientes primero)
      final querySnapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .orderBy('fecha', descending: false) // Más cercanos primero
          .get();

      // Convertir documentos a objetos EventoAcademico
      final eventos = querySnapshot.docs.map((doc) {
        return EventoAcademico.fromFirestore(doc.data(), doc.id);
      }).toList();

      print('${eventos.length} eventos obtenidos (una vez)');
      return eventos;
    } catch (e) {
      print('Error al obtener eventos: $e');
      return [];
    }
  }

  /// Obtiene un stream de los próximos eventos (futuros, ordenados por fecha)
  /// Ideal para widgets que muestran próximos eventos y se actualizan automáticamente
  Stream<List<EventoAcademico>> obtenerProximosEventosStream({int limite = 5}) {
    try {
      if (_userId == null) {
        return Stream.value([]);
      }

      final ahora = Timestamp.fromDate(DateTime.now());

      return _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .where('fecha', isGreaterThanOrEqualTo: ahora) // Solo eventos futuros
          .orderBy('fecha', descending: false) // Orden cronológico
          .limit(limite) // Límite de resultados
          .snapshots() // Stream en tiempo real
          .map((querySnapshot) {
        final eventos = querySnapshot.docs.map((doc) {
          return EventoAcademico.fromFirestore(doc.data(), doc.id);
        }).toList();

        print('Stream próximos eventos: ${eventos.length} eventos');
        return eventos;
      });
    } catch (e) {
      print('Error en obtenerProximosEventosStream: $e');
      return Stream.value([]);
    }
  }

  // =============================================
  // MÉTODOS ESPECIALIZADOS
  // =============================================

  /// Obtiene los próximos eventos (método tradicional, una sola vez)
  Future<List<EventoAcademico>> obtenerProximosEventos({int limite = 5}) async {
    try {
      if (_userId == null) {
        return [];
      }

      // Consulta eventos desde hoy en adelante, ordenados por fecha
      final ahora = DateTime.now();
      final querySnapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .where('fecha', isGreaterThanOrEqualTo: ahora)
          .orderBy('fecha', descending: false)
          .limit(limite)
          .get();

      final eventos = querySnapshot.docs.map((doc) {
        return EventoAcademico.fromFirestore(doc.data(), doc.id);
      }).toList();

      print('${eventos.length} próximos eventos obtenidos');
      return eventos;
    } catch (e) {
      print(' Error al obtener próximos eventos: $e');
      return [];
    }
  }

  /// Cuenta el total de eventos del usuario
  Future<int> contarEventos() async {
    try {
      if (_userId == null) {
        return 0;
      }

      final querySnapshot = await _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error al contar eventos: $e');
      return 0;
    }
  }

  /// Obtiene un stream del conteo de eventos (se actualiza automáticamente)
  Stream<int> contarEventosStream() {
    try {
      if (_userId == null) {
        return Stream.value(0);
      }

      return _firestore
          .collection('usuarios')
          .doc(_userId)
          .collection('eventos_academicos')
          .snapshots()
          .map((snapshot) => snapshot.size)
          .handleError((error) {
        print('Error en contarEventosStream: $error');
        return 0;
      });
    } catch (e) {
      print('Error en contarEventosStream: $e');
      return Stream.value(0);
    }
  }
}
