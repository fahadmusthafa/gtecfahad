import 'package:flutter/material.dart';
import 'package:lms/contants/gtec_token.dart';
import 'package:lms/models/admin_model.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:lms/screens/admin/course_management/quiz.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminModuleLessonsScreen extends StatefulWidget {
  final int moduleId;
  final int courseId;
  final int batchId;
  final String moduleTitle;
  final String courseName;

  const AdminModuleLessonsScreen({
    Key? key,
    required this.moduleId,
    required this.courseId,
    required this.batchId,
    required this.moduleTitle,
    required this.courseName,
  }) : super(key: key);

  @override
  State<AdminModuleLessonsScreen> createState() =>
      _AdminModuleLessonsScreenState();
}

class _AdminModuleLessonsScreenState extends State<AdminModuleLessonsScreen> {
  bool isLoading = true;
  bool isCreatingAssignment = false;
  String? error;

  final TextEditingController assignmentTitleController =
      TextEditingController();
  final TextEditingController assignmentDescriptionController =
      TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _loadAssignments();
  }

  @override
  void dispose() {
    assignmentTitleController.dispose();
    assignmentDescriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await Provider.of<AdminAuthProvider>(context, listen: false)
          .getAssignmentsForModule(widget.moduleId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _createAssignment() async {
    if (assignmentTitleController.text.isEmpty ||
        assignmentDescriptionController.text.isEmpty ||
        dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isCreatingAssignment = true);
    try {
      await Provider.of<AdminAuthProvider>(context, listen: false)
          .createAssignmentProvider(
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        // Replace with actual batch ID
        title: assignmentTitleController.text,
        description: assignmentDescriptionController.text,
        dueDate: dueDateController.text,
      );

      assignmentTitleController.clear();
      assignmentDescriptionController.clear();
      dueDateController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating assignment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isCreatingAssignment = false);
    }
  }

  void _showEditAssignmentDialog(
      BuildContext context, AssignmentModel assignment) {
    final TextEditingController editassignmentTitleController =
        TextEditingController(text: assignment.title);
    final TextEditingController editassignmentDescriptionController =
        TextEditingController(text: assignment.description);
    final editdueDateController = TextEditingController(
        text: assignment.dueDate.toIso8601String().split('T')[0]);
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit,
                      size: 24, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text('Edit assignment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'assignment Title*',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: editassignmentTitleController,
                        decoration: InputDecoration(
                          hintText: 'Enter assignment title',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'assignment Content*',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: editassignmentDescriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter assignment content',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.all(12),
                        ),
                        maxLines: 4,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Due Date*',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: editdueDateController,
                        decoration: InputDecoration(
                          hintText: 'Enter due date (optional)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: Text('Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                      )),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (editassignmentTitleController.text
                                  .trim()
                                  .isEmpty ||
                              editassignmentDescriptionController.text
                                  .trim()
                                  .isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Please fill all required fields'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isUpdating = true;
                          });

                          try {
                            final provider = Provider.of<AdminAuthProvider>(
                                context,
                                listen: false);

                            // Changed function name from SuperAdminUpdatelesson to SuperAdminUpdateAssignment
                            await provider.SuperAdminUpdateAssignment(
                              widget.courseId,
                              editassignmentTitleController.text.trim(),
                              editassignmentDescriptionController.text.trim(),
                              assignment.assignmentId,
                              widget.moduleId,
                            );

                            Navigator.of(context).pop();

                            // Change this to refresh assignments instead of lessons
                            await _loadAssignments(); // Make sure this function exists

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Assignment updated successfully'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error updating assignment: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } finally {
                            setState(() {
                              isUpdating = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('Update',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditLessonDialog(BuildContext context, AdminLessonmodel lesson) {
    final TextEditingController editTitleController =
        TextEditingController(text: lesson.title);
    final TextEditingController editContentController =
        TextEditingController(text: lesson.content);
    final TextEditingController editVideoLinkController =
        TextEditingController(text: lesson.videoLink);
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Lesson',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600, // Set desired dialog width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editTitleController,
                      decoration: InputDecoration(
                        labelText: 'Lesson Title*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editContentController,
                      decoration: InputDecoration(
                        labelText: 'Lesson Content*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editVideoLinkController,
                      decoration: InputDecoration(
                        labelText: 'Video Link (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isUpdating
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isUpdating
                            ? null
                            : () async {
                                if (editTitleController.text.trim().isEmpty ||
                                    editContentController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please fill all required fields'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isUpdating = true;
                                });

                                try {
                                  final provider =
                                      Provider.of<AdminAuthProvider>(context,
                                          listen: false);

                                  await provider.AdminUpdatelessonprovider(
                                    widget.courseId,
                                    widget.batchId,
                                    editTitleController.text.trim(),
                                    editContentController.text.trim(),
                                    lesson.lessonId,
                                    widget.moduleId,
                                  );

                                  Navigator.of(context).pop();

                                  // Refresh lessons
                                  await _loadLessons();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Lesson updated successfully!'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error updating lesson: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isUpdating = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadLessons() async {
    try {
      await Provider.of<AdminAuthProvider>(context, listen: false)
          .AdminfetchLessonsForModuleProvider(
              widget.courseId, widget.batchId, widget.moduleId);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showCreateLessonDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _CreateLessonDialog(
        courseId: widget.courseId,
        batchId: widget.batchId,
        moduleId: widget.moduleId,
      ),
    );

    // Refresh lessons after creating one
    _loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, provider, child) {
        final lessons = provider.getLessonsForModule(widget.moduleId);
        final assignments = provider.fetchAssignmentForModuleProvider(
            widget.moduleId, widget.courseId);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue, // Set the color of the AppBar
            title:
                Text(widget.moduleTitle, style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white), // Back arrow icon
              onPressed: () {
                Navigator.pop(
                    context); // Pop the current screen from the navigation stack
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuizCreatorScreen(
                              moduleId: widget.moduleId,
                              courseId: widget.courseId,
                              batchId: widget.batchId,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white, // Text color of the button
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Button padding
                ),
                child: Text(
                  'Button', // Text of the button
                  style:
                      TextStyle(color: Colors.blue), // Text color of the button
                ),
              ),
              const SizedBox(
                  width: 16), // To add spacing after the button if needed
            ],
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lessons',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _showCreateLessonDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Create Lesson',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Lessons List
                        lessons.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.menu_book,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No lessons available for this module',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: lessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = lessons[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 187, 234, 255),
                                        width: 2,
                                      ),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(16.0),
                                      title: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              (index + 1).toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lesson.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  lesson.content,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_note,
                                                color: Colors.black),
                                            onPressed: () =>
                                                _showEditLessonDialog(
                                                    context, lesson),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_sweep_outlined,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Delete Lesson'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this lesson?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await Provider.of<
                                                              AdminAuthProvider>(
                                                          context,
                                                          listen: false)
                                                      .admindeletelessonprovider(
                                                    widget.courseId,
                                                    widget.batchId,
                                                    widget.moduleId,
                                                    lesson.lessonId,
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Lesson deleted successfully!')),
                                                  );
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Failed to delete lesson: $error')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        SizedBox(height: 16),
                        // Assignment section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.assignment,
                                        color: Theme.of(context).primaryColor),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create Assignment',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: assignmentTitleController,
                                  decoration: InputDecoration(
                                    labelText: 'Assignment Title*',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: assignmentDescriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Assignment Description*',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                  ),
                                  maxLines: 3,
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: dueDateController,
                                  decoration: InputDecoration(
                                    labelText: 'Due Date*',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365)),
                                    );
                                    if (picked != null) {
                                      dueDateController.text = picked
                                          .toIso8601String()
                                          .split('T')[0];
                                    }
                                  },
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isCreatingAssignment
                                        ? null
                                        : () async {
                                            if (assignmentTitleController
                                                    .text.isEmpty ||
                                                assignmentDescriptionController
                                                    .text.isEmpty ||
                                                dueDateController
                                                    .text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Please fill all required fields'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() =>
                                                isCreatingAssignment = true);
                                            try {
                                              await Provider.of<
                                                          AdminAuthProvider>(
                                                      context,
                                                      listen: false)
                                                  .createAssignmentProvider(
                                                courseId: widget.courseId,
                                                moduleId: widget.moduleId,
                                                title: assignmentTitleController
                                                    .text,
                                                description:
                                                    assignmentDescriptionController
                                                        .text,
                                                dueDate: dueDateController.text,
                                              );

                                              assignmentTitleController.clear();
                                              assignmentDescriptionController
                                                  .clear();
                                              dueDateController.clear();

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Assignment created successfully!'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              // Refresh the assignments list
                                              _loadAssignments();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error creating assignment: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } finally {
                                              setState(() =>
                                                  isCreatingAssignment = false);
                                            }
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: isCreatingAssignment
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text('Create Assignment'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        if (isLoading)
                          Center(child: CircularProgressIndicator())
                        else if (error != null)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                SizedBox(height: 16),
                                Text(error!,
                                    style: TextStyle(color: Colors.red)),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadAssignments,
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else
                          Consumer<AdminAuthProvider>(
                            builder: (context, provider, child) {
                              final assignments = provider
                                  .getAssignmentsForModule(widget.moduleId);

                              if (assignments.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.pending_actions,
                                          size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'No Assignments available for this module',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: assignments.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final assignment = assignments[index];
                                  return Card(
                                    elevation: 2,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        assignment.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Text(assignment.description),
                                          SizedBox(height: 4),
                                          Text(
                                            'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            onPressed: () =>
                                                _showEditAssignmentDialog(
                                                    context, assignment),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Delete Assignment'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this assignment?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],  
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                try {
                                                  // Show loading indicator
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  await Provider.of<
                                                              AdminAuthProvider>(
                                                          context,
                                                          listen: false)
                                                      .superadmindeleteassignmentprovider(
assignment.assignmentId,   widget.courseId,widget.moduleId,
                                                  );

                                                  // Show success message
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Assignment deleted successfully!'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );

                                                  // Refresh the assignments list
                                                  await _loadAssignments();
                                                } catch (error) {
                                                  // Show error message
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Failed to delete assignment: $error'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } finally {
                                                  // Hide loading indicator
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _CreateLessonDialog extends StatefulWidget {
  final int courseId;
  final int batchId;
  final int moduleId;

  const _CreateLessonDialog({
    Key? key,
    required this.courseId,
    required this.batchId,
    required this.moduleId,
  }) : super(key: key);

  @override
  State<_CreateLessonDialog> createState() => _CreateLessonDialogState();
}

class _CreateLessonDialogState extends State<_CreateLessonDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();
  bool isCreatingLesson = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    videoLinkController.dispose();
    super.dispose();
  }

  Future<void> _createLesson() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isCreatingLesson = true);
    try {
      await Provider.of<AdminAuthProvider>(context, listen: false)
          .Admincreatelessonprovider(
        widget.courseId,
        widget.batchId,
        widget.moduleId,
        contentController.text,
        titleController.text,
        videoLinkController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson created successfully!')),
      );

      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating lesson: $e')),
      );
    } finally {
      setState(() => isCreatingLesson = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCreatingLesson = false; // Local state for loading indicator

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Create New Lesson',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 600, // Set desired dialog width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Lesson Title*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Lesson Content*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: videoLinkController,
              decoration: InputDecoration(
                labelText: 'Video Link (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed:
                    isCreatingLesson ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isCreatingLesson
                    ? null
                    : () async {
                        if (titleController.text.trim().isEmpty ||
                            contentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isCreatingLesson = true;
                        });

                        try {
                          // Call the create lesson logic
                          await _createLesson();

                          // Refresh lessons to show the newly created lesson
                          await Provider.of<AdminAuthProvider>(context,
                                  listen: false)
                              .AdminfetchLessonsForModuleProvider(
                                  widget.courseId,
                                  widget.batchId,
                                  widget.moduleId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lesson created successfully!'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error creating lesson: ${e.toString()}'),
                            ),
                          );
                        } finally {
                          setState(() {
                            isCreatingLesson = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isCreatingLesson
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
