import 'package:flutter/material.dart';
import 'package:lms/models/admin_model.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:lms/screens/admin/course_management/quiz.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminModuleAddScreen extends StatefulWidget {
  final int courseId;
  final int batchId;
  final String courseName;

  const AdminModuleAddScreen({
    Key? key,
    required this.courseId,
    required this.batchId,
    required this.courseName,
  }) : super(key: key);

  @override
  State<AdminModuleAddScreen> createState() => _AdminModuleAddScreenState();
}

class _AdminModuleAddScreenState extends State<AdminModuleAddScreen> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  AdminModulemodel? selectedModule;
  bool isLoading = false;
  bool isFabMenuOpen = false;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      isFabMenuOpen = !isFabMenuOpen;
      if (isFabMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  void initState() {
    super.initState();
    _loadModules();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  Future<void> _loadModules() async {
    await Provider.of<AdminAuthProvider>(context, listen: false)
        .AdminfetchModulesForCourseProvider(widget.courseId, widget.batchId);
  }

  Future<void> _loadLessonsAndAssignments() async {
    if (selectedModule != null) {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await provider.AdminfetchLessonsForModuleProvider(
        widget.courseId,
        widget.batchId,
        selectedModule!.moduleId,
      );
      await provider.getAssignmentsForModule(selectedModule!.moduleId);
    }
  }

  void _showEditModuleDialog(BuildContext context, AdminModulemodel module) {
    final TextEditingController editTitleController =
        TextEditingController(text: module.title);
    final TextEditingController editContentController =
        TextEditingController(text: module.content);
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
                'Edit Module',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editTitleController,
                      decoration: InputDecoration(
                        labelText: 'Module Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editContentController,
                      decoration: InputDecoration(
                        labelText: 'Module Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
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
                                      content:
                                          Text('Please fill all required fields'),
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

                                  await provider.AdminUpdatemoduleprovider(
                                    widget.courseId,
                                    widget.batchId,
                                    editTitleController.text.trim(),
                                    editContentController.text.trim(),
                                    module.moduleId,
                                  );

                                  Navigator.of(context).pop();
                                  await _loadModules();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Module updated successfully!'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error updating module: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isUpdating = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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

  void _showCreateModuleDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    bool isCreating = false;

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
                'Create Module',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Module Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Module Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isCreating
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
                        onPressed: isCreating
                            ? null
                            : () async {
                                if (titleController.text.trim().isEmpty ||
                                    contentController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please fill all required fields'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isCreating = true;
                                });

                                try {
                                  final provider =
                                      Provider.of<AdminAuthProvider>(context,
                                          listen: false);

                                  await provider.Admincreatemoduleprovider(
                                    titleController.text.trim(),
                                    contentController.text.trim(),
                                    widget.courseId,
                                    widget.batchId,
                                  );

                                  Navigator.of(context).pop();
                                  await _loadModules();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Module created successfully!'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error creating module: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isCreating = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isCreating
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
                                'Create',
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

  Widget _buildModuleDropdown(List<AdminModulemodel> modules) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedModule?.title ?? 'Select Module',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedModule = module;
                      isExpanded = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: index == modules.length - 1 
                              ? Colors.transparent 
                              : const Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            module.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (selectedModule?.moduleId == module.moduleId)
                          const Icon(Icons.check, color: Colors.blue),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          if (selectedModule != null && !isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedModule!.content,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        onPressed: () => _showEditModuleDialog(context, selectedModule!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined),
                        onPressed: () => _handleDeleteModule(selectedModule!),
                      ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => AdminModuleLessonsScreen(
                      //           courseId: widget.courseId,
                      //           batchId: widget.batchId,
                      //           moduleId: selectedModule!.moduleId,
                      //           moduleTitle: selectedModule!.title,
                      //           courseName: widget.courseName,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.blue,
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 8,
                      //     ),
                      //   ),
                      //   child: const Text(
                      //     'View Lessons',
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  

  Future<void> _handleDeleteModule(AdminModulemodel module) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: const Text('Are you sure you want to delete this module?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final provider = Provider.of<AdminAuthProvider>(context, listen: false);
        await provider.admindeletemoduleprovider(
          widget.courseId,
          widget.batchId,
          module.moduleId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module deleted successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete module: $error')),
        );
      }
    }
  }

  Widget _buildLessonsAndAssignmentsView() {
    if (selectedModule == null) return SizedBox.shrink();

    return Consumer<AdminAuthProvider>(
      builder: (context, provider, child) {
        final lessons = provider.getLessonsForModule(selectedModule!.moduleId);
        final assignments = provider.getAssignmentsForModule(selectedModule!.moduleId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Module Content',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizCreatorScreen(
                            moduleId: selectedModule!.moduleId,
                            courseId: widget.courseId,
                            batchId: widget.batchId,
                          ),
                        ),
                      ),
                      icon: Icon(Icons.quiz, color: Colors.white),
                      label: Text('Create Quiz', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _CreateAssignmentDialog(
                        moduleId: selectedModule!.moduleId,
                        courseId: widget.courseId,
                      ),
                      icon: Icon(Icons.assignment, color: Colors.white),
                      label: Text('Add Assignment', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _CreateLessonDialog(
                        courseId: widget.courseId,
                        batchId: widget.batchId,
                        moduleId: selectedModule!.moduleId,
                      ),
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text('Add Lesson', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Lessons Section
            Text(
              'Lessons',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLessonsList(lessons),
            
            const SizedBox(height: 32),
            
            // Assignments Section
            Text(
              'Assignments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAssignmentsList(assignments),
          ],
        );
      },
    );
  }

  Widget _buildLessonsList(List<AdminLessonmodel> lessons) {
    if (lessons.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.menu_book, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No lessons available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue.shade100),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text('${index + 1}'),
            ),
            title: Text(
              lesson.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(lesson.content),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // IconButton(
                //   icon: Icon(Icons.edit),
                //   onPressed: () => _showEditLessonDialog(context, lesson),
                // ),
                // IconButton(
                //   icon: Icon(Icons.delete),
                //   onPressed: () => _handleDeleteLesson(lesson),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsList(List<AssignmentModel> assignments) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.assignment, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No assignments available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.shade100),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.assignment, color: Colors.green),
            ),
            title: Text(
              assignment.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.description),
                SizedBox(height: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // IconButton(
                //   icon: Icon(Icons.edit),
                //   onPressed: () => _showEditAssignmentDialog(context, assignment),
                // ),
                // IconButton(
                //   icon: Icon(Icons.delete),
                //   onPressed: () => _handleDeleteAssignment(assignment),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Module Management', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MODULES',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            Consumer<AdminAuthProvider>(
              builder: (context, provider, child) {
                final modules = provider.getModulesForCourse(widget.courseId);
                
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    _buildModuleDropdown(modules),
                    if (selectedModule != null) _buildLessonsAndAssignmentsView(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create Module Button
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.small(
                heroTag: 'createModule',
                onPressed: () {
                  _showCreateModuleDialog(context);
                  _toggleFabMenu();
                },
                backgroundColor: Colors.blue[700],
                child: const Icon(
                  Icons.create_new_folder,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Main FAB
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: _toggleFabMenu,
            backgroundColor: Colors.blue,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animationController,
              color: Colors.white,
            ),
          ),
        ],
      ),
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

class _CreateAssignmentDialog extends StatefulWidget {
  final int moduleId;
  final int courseId;

  const _CreateAssignmentDialog({
    Key? key,
    required this.moduleId,
    required this.courseId,
  }) : super(key: key);

  @override
  State<_CreateAssignmentDialog> createState() =>
      _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<_CreateAssignmentDialog> {
  final TextEditingController assignmentTitleController =
      TextEditingController();
  final TextEditingController assignmentDescriptionController =
      TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  bool isCreatingAssignment = false;

  @override
  void dispose() {
    assignmentTitleController.dispose();
    assignmentDescriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> _createAssignment() async {
    if (assignmentTitleController.text.isEmpty ||
        assignmentDescriptionController.text.isEmpty ||
        dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isCreatingAssignment = true);
    try {
      await Provider.of<AdminAuthProvider>(context, listen: false)
          .createAssignmentProvider(
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        title: assignmentTitleController.text.trim(),
        description: assignmentDescriptionController.text.trim(),
        dueDate: dueDateController.text.trim(),
      );

      Navigator.of(context).pop(); // Close the dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating assignment: $e')),
      );
    } finally {
      setState(() => isCreatingAssignment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Create New Assignment',
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
              controller: assignmentTitleController,
              decoration: InputDecoration(
                labelText: 'Assignment Title*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: assignmentDescriptionController,
              decoration: InputDecoration(
                labelText: 'Assignment Description*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: dueDateController,
              decoration: InputDecoration(
                labelText: 'Due Date*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  dueDateController.text = picked.toIso8601String().split('T')[0];
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isCreatingAssignment
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
                onPressed: isCreatingAssignment ? null : _createAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isCreatingAssignment
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
        ),
      ],
    );
  }
}
