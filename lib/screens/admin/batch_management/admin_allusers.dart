import 'package:flutter/material.dart';
import 'package:lms/models/admin_model.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:lms/screens/admin/batch_management/admin_createlivelink.dart';
import 'package:provider/provider.dart';

class AdminAllUsersPage extends StatefulWidget {
  const AdminAllUsersPage(
      {Key? key, required this.courseId, required this.batchId})
      : super(key: key);

  final int courseId;
  final int batchId;

  @override
  _AdminAllUsersPageState createState() => _AdminAllUsersPageState();
}

class _AdminAllUsersPageState extends State<AdminAllUsersPage> {
  @override
  void initState() {
    super.initState();

    // Fetch live link and users data when the screen initializes
    Future.microtask(() {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      provider.AdminfetchLivelinkForModuleProvider(
        widget.courseId,
        widget.batchId,
      );
      provider.AdminfetchallusersProvider();
    });
  }

  void _assignUser(int userId) async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);

    try {
      await provider.assignUserToBatchProvider(
        courseId: widget.courseId,
        batchId: widget.batchId,
        userId: userId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User assigned to batch successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign user: $e')),
      );
    }
  }

  void _deleteUser(int userId) async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);

    try {
      await provider.AdmindeleteUserFromBatchprovider(
        courseId: widget.courseId,
        batchId: widget.batchId,
        userId: userId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted from batch successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);
    final liveLinkFuture = provider.AdminfetchLivelinkForModuleProvider(
      widget.batchId,
      widget.courseId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('All Users'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      CreateLiveLinkDialog(widget.courseId, widget.batchId),
                );
              },
              child: const Text('Create Live Link'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<List<AdminLiveLinkResponse>>(
            future: provider.getLiveForbatch(
                widget.batchId), // Now using the updated method
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No live links available.'),
                );
              } else {
                final liveLinks = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: liveLinks.map((liveLink) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Link: ${liveLink.liveLink}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Live Start Time: ${liveLink.liveStartTime}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Divider(),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),

          const Divider(),

          // Section to display all users
          Expanded(
            child: provider.users == null
                ? const Center(child: CircularProgressIndicator())
                : provider.users!.isEmpty
                    ? const Center(child: Text('No users found.'))
                    : ListView.builder(
                        itemCount: provider.users!.length,
                        itemBuilder: (context, index) {
                          final user = provider.users![index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(user.name[0].toUpperCase()),
                              ),
                              title: Text(user.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${user.email}'),
                                  Text('Phone: ${user.phoneNumber}'),
                                  Text('Role: ${user.role}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _assignUser(user.userId),
                                    child: const Text('Add to Batch'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _deleteUser(user.userId),
                                    child: const Text('Delete from Batch'),
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
