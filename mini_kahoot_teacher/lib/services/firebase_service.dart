import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // Login anónimo
  static Future<void> login() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // Generar código único
  static Future<int> generateUniqueCode() async {
    int code;
    bool exists;

    do {
      code = Random().nextInt(900000) + 100000;
      final query = await _db
          .collection('games')
          .where('code', isEqualTo: code)
          .where('status', isEqualTo: 'waiting')
          .get();
      exists = query.docs.isNotEmpty;
    } while (exists);

    return code;
  }

  // Crear juego
  static Future<String> createGame() async {
    await login();
    final code = await generateUniqueCode();

    final doc = await _db.collection('games').add({
      'code': code,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // Stream de jugadores en tiempo real
  static Stream<QuerySnapshot> playersStream(String gameId) {
    return _db
        .collection('games')
        .doc(gameId)
        .collection('players')
        .snapshots();
  }

  // Lista de preguntas estática
  static const List<Map<String, dynamic>> questions = [
    {
      'question': '¿Cuál es el lenguaje de programación de Flutter?',
      'options': ['Java', 'Dart', 'Swift', 'Kotlin'],
      'correct': 1,
    },
    {
      'question': '¿Quién desarrolló Flutter?',
      'options': ['Microsoft', 'Apple', 'Google', 'Meta'],
      'correct': 2,
    },
    {
      'question': '¿Cómo se llama el widget raíz en la mayoría de apps?',
      'options': ['MaterialApp', 'RootApp', 'MainWidget', 'AppContainer'],
      'correct': 0,
    },
  ];

  // Iniciar la partida con preguntas
  static Future<void> startGame(String gameId) async {
    await _db.collection('games').doc(gameId).update({
      'status': 'playing',
      'currentQuestionIndex': 0,
      'questions': questions,
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  // Pasar a la siguiente pregunta
  static Future<void> nextQuestion(String gameId, int nextIndex) async {
    await _db.collection('games').doc(gameId).update({
      'currentQuestionIndex': nextIndex,
    });
  }
}
