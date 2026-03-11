import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StudentFirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login anónimo
  Future<UserCredential> login() async {
    return await _auth.signInAnonymously();
  }

  // Unirse a una partida
  Future<bool> joinGame(String code, String playerName) async {
    try {
      final int? codeInt = int.tryParse(code);
      if (codeInt == null) return false;

      // Buscar la partida con el código proporcionado
      final query = await _db
          .collection('games')
          .where('code', isEqualTo: codeInt)
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return false; // Partida no encontrada o ya empezada
      }

      final gameId = query.docs.first.id;

      // Añadir al jugador a la subcolección 'players'
      await _db
          .collection('games')
          .doc(gameId)
          .collection('players')
          .doc(_auth.currentUser!.uid)
          .set({'name': playerName, 'joinedAt': FieldValue.serverTimestamp()});

      return true;
    } catch (e) {
      debugPrint('Error al unirse a la partida: $e');
      return false;
    }
  }

  // Stream para escuchar cambios en la partida (estado, preguntas)
  Stream<DocumentSnapshot> gameStream(String gameCode) {
    final int? codeInt = int.tryParse(gameCode);
    if (codeInt == null) return const Stream.empty();

    return _db
        .collection('games')
        .where('code', isEqualTo: codeInt)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.first);
  }

  // Enviar respuesta
  Future<void> submitAnswer(
    String gameCode,
    int questionIndex,
    int answerIndex,
  ) async {
    final int? codeInt = int.tryParse(gameCode);
    if (codeInt == null) return;

    final query = await _db
        .collection('games')
        .where('code', isEqualTo: codeInt)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final gameId = query.docs.first.id;
      await _db
          .collection('games')
          .doc(gameId)
          .collection('players')
          .doc(_auth.currentUser!.uid)
          .collection('answers')
          .doc(questionIndex.toString())
          .set({
            'answerIndex': answerIndex,
            'submittedAt': FieldValue.serverTimestamp(),
          });
    }
  }
}
