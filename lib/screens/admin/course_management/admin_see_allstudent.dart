import 'package:flutter/material.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:provider/provider.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({Key? key}) : super(key: key);

  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AdminAuthProvider>(context, listen: false).AdminfetchallusersProvider();
    });
  }
 void _approval(int userId, String role) async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);

    try {
      await provider.adminApproveUserprovider(
        role: role,
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
  @override
  Widget build(BuildContext context) {
    final allUsersProvider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: allUsersProvider.users!.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allUsersProvider.users!.length,
              itemBuilder: (context, index) {
                final user = allUsersProvider.users![index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                   trailing:  ElevatedButton(
                              onPressed: () => _approval(user.userId, user.role),
                              child: const Text('Approve'),
                            ),
                  ),
                );
              },
            ),
    );
  }
}