import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lms/provider/authprovider.dart';

class AdminTeacherAssignmentPage extends StatefulWidget {
  const AdminTeacherAssignmentPage({
    Key? key,
    required this.courseId,
    required this.batchId,
  }) : super(key: key);

  final int courseId;
  final int batchId;

  @override
  _AdminTeacherAssignmentPageState createState() => _AdminTeacherAssignmentPageState();
}

class _AdminTeacherAssignmentPageState extends State<AdminTeacherAssignmentPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<int> teachersInBatch = {};

  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      provider.AdminfetchallusersProvider();
    });
  }

  void _showActionConfirmation({
    required String title,
    required String message,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _assignTeacher(int userId) {
    _showActionConfirmation(
      title: 'Assign Teacher',
      message: 'Are you sure you want to assign this teacher to the batch?',
      onConfirm: () async {
        final provider = Provider.of<AdminAuthProvider>(context, listen: false);
        try {
          await provider.assignUserToBatchProvider(
            courseId: widget.courseId,
            batchId: widget.batchId,
            userId: userId,
          );
          setState(() {
            teachersInBatch.add(userId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Teacher assigned successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign teacher: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Teachers'),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: lightBlue,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search teachers...',
                prefixIcon: Icon(Icons.search, color: primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mediumBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mediumBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryBlue, width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: provider.users == null
                ? Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                : provider.users!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: mediumBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No teachers found',
                              style: TextStyle(
                                fontSize: 18,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.users!.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final user = provider.users![index];
                          
                          // Only show users with teacher role
                          if (user.role.toLowerCase() != 'teacher') {
                            return const SizedBox.shrink();
                          }

                          if (!user.name.toLowerCase().contains(searchQuery) &&
                              !user.email.toLowerCase().contains(searchQuery)) {
                            return const SizedBox.shrink();
                          }

                          final bool isInBatch = teachersInBatch.contains(user.userId);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: mediumBlue, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: primaryBlue,
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 16,
                                              color: primaryBlue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              user.phoneNumber,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.school,
                                              size: 16,
                                              color: primaryBlue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Teacher',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: isInBatch 
                                      ? null 
                                      : () => _assignTeacher(user.userId),
                                    icon: const Icon(Icons.person_add),
                                    label: Text(isInBatch ? 'Added' : 'Assign'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isInBatch 
                                        ? Colors.grey
                                        : primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}