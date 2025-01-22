import 'package:flutter/material.dart';

class ModulesList extends StatelessWidget {
  final StudentModel course;

  const ModulesList({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<StudentAuthProvider>(context, listen: false)
          .fetchModulesForSelectedCourse(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Consumer<StudentAuthProvider>(
          builder: (context, provider, child) {
            if (provider.modules.isEmpty) {
              return const Center(child: Text('No modules available'));
            }
            return ListView.builder(
              itemCount: provider.modules.length,
              itemBuilder: (context, index) {
                final module = provider.modules[index];
                return ModuleExpansionTile(
                  module: module,
                  courseId: course.courseId,
                  batchId: course.batchId,
                );
              },
            );
          },
        );
      },
    );
  }
}

class ModuleExpansionTile extends StatefulWidget {
  final StudentModuleModel module;
  final int courseId;
  final int batchId;

  const ModuleExpansionTile({
    super.key,
    required this.module,
    required this.courseId,
    required this.batchId,
  });

  @override
  State<ModuleExpansionTile> createState() => _ModuleExpansionTileState();
}

class _ModuleExpansionTileState extends State<ModuleExpansionTile> {
  bool isExpanded = false;
  bool isLoading = false;
  List<StudentLessonModel> lessons = [];
  List<StudentAssignmentModel> assignments = [];
  List<StudentQuizmodel> quizzes = [];

  Future<void> loadModuleContent() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final provider = Provider.of<StudentAuthProvider>(context, listen: false);
      provider.setSelectedModuleId(widget.module.moduleId);
      await provider.fetchLessonsAndAssignmentsquiz();
      await provider.fetchliveForSelectedCourse();

      if (mounted) {
        setState(() {
          lessons = provider.lessons;
          assignments = provider.assignments;
          quizzes = provider.quiz;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading module content: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Progress Circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 3,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.3),
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    lessons.length.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Text(
                  widget.module.title ?? 'No title available',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF666666),
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });

                  if (isExpanded) {
                    loadModuleContent();
                  }
                },
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE)),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      ...lessons.map((lesson) => _buildExpandedContent(
                            title: lesson.title,
                            content: lesson.content,
                            icon: Icons.book_outlined,
                            buttonText: "View Lesson",
                            onPressed: () async {
                              final Uri url = Uri.parse(lesson.videoLink);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                throw 'Could not launch ${lesson.videoLink}';
                              }
                            },
                          )),
                      ...assignments.map((assignment) => _buildExpandedContent(
                            title: assignment.title,
                            content: assignment.description,
                            icon: Icons.assignment_outlined,
                            buttonText: "View Assignment",
                            onPressed: () {
                              // Navigate to AssignmentDetailsPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AssignmentSubmissionPage(
                                          assignment: assignment),
                                ),
                              );
                            },
                          )),
                      ...quizzes.map((quiz) => _buildExpandedContent(
                            title: quiz.name,
                            content: quiz.description,
                            icon: Icons.quiz_outlined,
                            buttonText: "Start Quiz",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuizDetailScreen(quiz: quiz),
                                ),
                              );
                            },
                          )),
                    ],
                  ),
          ],
        ],
      ),
    );
  }
}
