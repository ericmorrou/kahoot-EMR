import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String? gameId;
  int? gameCode;
  String status = 'waiting';
  int currentQuestionIndex = 0;
  bool _isCreating = false;

  void _createGame() async {
    setState(() => _isCreating = true);
    try {
      final id = await FirebaseService.createGame();
      final doc = await FirebaseFirestore.instance
          .collection('games')
          .doc(id)
          .get();

      if (!mounted) return;

      setState(() {
        gameId = id;
        gameCode = doc['code'];
        status = 'waiting';
        _isCreating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear la partida: $e')));
      debugPrint("Error creating game: $e");
    }
  }

  void _startGame() async {
    if (gameId != null) {
      await FirebaseService.startGame(gameId!);
      setState(() {
        status = 'playing';
        currentQuestionIndex = 0;
      });
    }
  }

  void _nextQuestion() async {
    if (gameId != null &&
        currentQuestionIndex < FirebaseService.questions.length - 1) {
      final nextIndex = currentQuestionIndex + 1;
      await FirebaseService.nextQuestion(gameId!, nextIndex);
      setState(() => currentQuestionIndex = nextIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profesor - Mini Kahoot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (gameId == null)
              _isCreating
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createGame,
                      child: const Text('Crear Kahoot'),
                    ),
            if (gameId != null) ...[
              Text(
                'Código del juego: $gameCode',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (status == 'waiting')
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Empezar Partida',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (status == 'playing') ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Pregunta ${currentQuestionIndex + 1}:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          FirebaseService
                              .questions[currentQuestionIndex]['question'],
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (currentQuestionIndex < FirebaseService.questions.length - 1)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: const Text('Siguiente Pregunta'),
                  )
                else
                  const Text(
                    '¡Fin de las preguntas!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Alumnos conectados:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.playersStream(gameId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Ningún alumno conectado aún'),
                      );
                    }
                    return ListView(
                      children: docs.map((doc) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(doc['name'] ?? 'Sin nombre'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
