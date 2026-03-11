import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class StudentGameScreen extends StatefulWidget {
  final String gameCode;

  const StudentGameScreen({super.key, required this.gameCode});

  @override
  State<StudentGameScreen> createState() => _StudentGameScreenState();
}

class _StudentGameScreenState extends State<StudentGameScreen> {
  final StudentFirebaseService _firebaseService = StudentFirebaseService();
  int? _lastAnsweredIndex;
  int? _currentQuestionIndex;

  void _submitAnswer(int index) async {
    if (_currentQuestionIndex != null) {
      await _firebaseService.submitAnswer(
        widget.gameCode,
        _currentQuestionIndex!,
        index,
      );
      setState(() {
        _lastAnsweredIndex = _currentQuestionIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Juego: ${widget.gameCode}')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseService.gameStream(widget.gameCode),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var gameData = snapshot.data!.data() as Map<String, dynamic>;
          String status = gameData['status'] ?? 'waiting';
          int questionIndex = gameData['currentQuestionIndex'] ?? 0;
          List questions = gameData['questions'] ?? [];

          // Actualizar índice actual para saber si hemos respondido
          if (_currentQuestionIndex != questionIndex) {
            _currentQuestionIndex = questionIndex;
          }

          if (status == 'waiting') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'Esperando a que el profesor inicie...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          if (status == 'playing' && questions.isNotEmpty) {
            var currentQuestion = questions[questionIndex];
            bool answered = _lastAnsweredIndex == questionIndex;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pregunta ${questionIndex + 1}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  if (answered)
                    Column(
                      children: [
                        Icon(Icons.check_circle, size: 100, color: Colors.blue),
                        SizedBox(height: 20),
                        Text(
                          '¡Respuesta enviada!',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text('Espera a la siguiente pregunta'),
                      ],
                    )
                  else ...[
                    Text(
                      currentQuestion['question'],
                      style: TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ...currentQuestion['options'].asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ElevatedButton(
                          onPressed: () => _submitAnswer(entry.key),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(entry.value),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          }

          return Center(child: Text('Estado: $status'));
        },
      ),
    );
  }
}
