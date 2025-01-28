import 'package:flutter/material.dart';
import 'package:lms/models/admin_model.dart';
import 'package:provider/provider.dart';
import 'package:lms/provider/authprovider.dart';


class QuizCreatorScreen extends StatefulWidget {
  final int courseId;
  final int moduleId;
  final int batchId;

  const QuizCreatorScreen({
    Key? key,
    required this.courseId,
    required this.moduleId,
    required this.batchId,
  }) : super(key: key);

  @override
  _QuizCreatorScreenState createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> questions = [];
  List<Quizmodel> quizzes = [];

  @override
  void initState() {
    super.initState();
    // _loadQuizzes();
  }

  // Future<void> _loadQuizzes() async {
  //   try {
  //     final provider = Provider.of<AdminAuthProvider>(context, listen: false);
  //     final fetchedQuizzes = await provider.fetchQuizzes(
  //       courseId: widget.courseId,
  //       moduleId: widget.moduleId,
  //     );

  //     if (mounted) {
  //       setState(() {
  //         quizzes = fetchedQuizzes;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       _showErrorSnackBar('Error loading quizzes: $e');
  //     }
  //   }
  // }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addNewQuestion() {
    if (mounted) {
      setState(() {
        questions.add({
          "text": "",
          "answers": List.generate(
              4,
              (index) => {
                    "text": "",
                    "isCorrect": false,
                  }),
        });
      });
    }
  }

  void _removeQuestion(int index) {
    if (mounted) {
      setState(() {
        questions.removeAt(index);
      });
    }
  }

  void _updateQuestionText(int questionIndex, String text) {
    if (mounted) {
      setState(() {
        questions[questionIndex]["text"] = text;
      });
    }
  }

  void _updateAnswerText(int questionIndex, int answerIndex, String text) {
    if (mounted) {
      setState(() {
        questions[questionIndex]["answers"][answerIndex]["text"] = text;
      });
    }
  }

  void _updateCorrectAnswer(int questionIndex, int answerIndex, bool value) {
    if (mounted) {
      setState(() {
        for (var answer in questions[questionIndex]["answers"]) {
          answer["isCorrect"] = false;
        }
        questions[questionIndex]["answers"][answerIndex]["isCorrect"] = value;
      });
    }
  }

  bool _validateQuestions() {
    if (questions.isEmpty) {
      _showErrorSnackBar('Please add at least one question');
      return false;
    }

    for (int i = 0; i < questions.length; i++) {
      var question = questions[i];
      if (question["text"].toString().trim().isEmpty) {
        _showErrorSnackBar('Question ${i + 1} must have text');
        return false;
      }

      bool hasCorrectAnswer = false;
      bool hasEmptyAnswer = false;

      for (var answer in question["answers"]) {
        if (answer["text"].toString().trim().isEmpty) {
          hasEmptyAnswer = true;
        }
        if (answer["isCorrect"]) {
          hasCorrectAnswer = true;
        }
      }

      if (hasEmptyAnswer) {
        _showErrorSnackBar('All answers in question ${i + 1} must have text');
        return false;
      }

      if (!hasCorrectAnswer) {
        _showErrorSnackBar('Question ${i + 1} must have one correct answer');
        return false;
      }
    }

    return true;
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate() || !_validateQuestions()) {
      return;
    }

    try {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await provider.createQuizProvider(
        batchId: widget.batchId,
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        questions: questions,
      );

      _showSuccessSnackBar('Quiz created successfully!');

      if (mounted) {
        setState(() {
          _nameController.clear();
          _descriptionController.clear();
          questions.clear();
          _isCreating = false;
        });
      }

      // await _loadQuizzes();
    } catch (e) {
      _showErrorSnackBar('Error creating quiz: $e');
    }
  }

  Widget _buildCreatorView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.quiz),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a quiz name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a quiz description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions (${questions.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addNewQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) => QuestionCard(
                questionIndex: index,
                questionData: questions[index],
                onQuestionTextChanged: (text) =>
                    _updateQuestionText(index, text),
                onAnswerTextChanged: (answerIndex, text) =>
                    _updateAnswerText(index, answerIndex, text),
                onCorrectAnswerChanged: (answerIndex, value) =>
                    _updateCorrectAnswer(index, answerIndex, value),
                onDelete: () => _removeQuestion(index),
              ),
            ),
            if (questions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveQuiz,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Quiz'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayView() {
    return Consumer<AdminAuthProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quizzes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No quizzes available',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (mounted) {
                      setState(() => _isCreating = true);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Quiz'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text('${index + 1}'),
                ),
                title: Text(quiz.name),
                subtitle: Text(
                  quiz.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  QuizDetailsView(quiz: quiz),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreating ? 'Create Quiz' : 'View Quizzes'),
        actions: [
          IconButton(
            icon: Icon(_isCreating ? Icons.view_list : Icons.add),
            onPressed: () {
              if (mounted) {
                setState(() {
                  _isCreating = !_isCreating;
                  if (_isCreating) {
                    _nameController.clear();
                    _descriptionController.clear();
                    questions.clear();
                  }
                });
              }
            },
          ),
        ],
      ),
      body: _isCreating ? _buildCreatorView() : _buildDisplayView(),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final int questionIndex;
  final Map<String, dynamic> questionData;
  final Function(String) onQuestionTextChanged;
  final Function(int, String) onAnswerTextChanged;
  final Function(int, bool) onCorrectAnswerChanged;
  final VoidCallback onDelete;

  const QuestionCard({
    Key? key,
    required this.questionIndex,
    required this.questionData,
    required this.onQuestionTextChanged,
    required this.onAnswerTextChanged,
    required this.onCorrectAnswerChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text('${questionIndex + 1}'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Question ${questionIndex + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: questionData["text"],
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.help_outline),
              ),
              maxLines: 2,
              onChanged: onQuestionTextChanged,
            ),
            const SizedBox(height: 16),
            Text(
              'Answers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              questionData["answers"].length,
              (answerIndex) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: questionData["answers"][answerIndex]
                            ["text"],
                        decoration: InputDecoration(
                          labelText: 'Answer ${answerIndex + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.check_box_outline_blank),
                        ),
                        onChanged: (text) =>
                            onAnswerTextChanged(answerIndex, text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Checkbox(
                          value: questionData["answers"][answerIndex]
                              ["isCorrect"],
                          onChanged: (value) => onCorrectAnswerChanged(
                              answerIndex, value ?? false),
                        ),
                        const Text('Correct'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizDetailsView extends StatelessWidget {
  final Quizmodel quiz;

  const QuizDetailsView({
    Key? key,
    required this.quiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quiz.questions.length,
            itemBuilder: (context, questionIndex) {
              final question = quiz.questions[questionIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text('${questionIndex + 1}'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              question.text,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...question.answers.asMap().entries.map((entry) {
                        final answerIndex = entry.key;
                        final answer = entry.value;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: answer.isCorrect
                                ? Colors.green
                                : Colors.grey.shade200,
                            child: Icon(
                              answer.isCorrect
                                  ? Icons.check
                                  : Icons.circle_outlined,
                              color:
                                  answer.isCorrect ? Colors.white : Colors.grey,
                            ),
                          ),
                          title: Text(
                            '${answerIndex + 1}. ${answer.text}',
                            style: TextStyle(
                              color: answer.isCorrect
                                  ? Colors.green
                                  : Colors.black,
                              fontWeight: answer.isCorrect
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Models

// Optional: Quiz Statistics Widget
class QuizStatistics extends StatelessWidget {
  final Quizmodel quiz;

  const QuizStatistics({
    Key? key,
    required this.quiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Questions',
                  quiz.questions.length.toString(),
                  Icons.question_answer,
                ),
                _buildStatItem(
                  context,
                  'Created',
                  _formatDate(quiz.createdAt ?? DateTime.now()),
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  context,
                  'Last Updated',
                  _formatDate(quiz.updatedAt ?? DateTime.now()),
                  Icons.update,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
