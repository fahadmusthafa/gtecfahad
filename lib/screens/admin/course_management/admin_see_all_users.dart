import 'package:flutter/material.dart';
import 'package:lms/models/admin_model.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:provider/provider.dart';

class UsersTabView extends StatefulWidget {
  const UsersTabView({Key? key}) : super(key: key);

  @override
  _UsersTabViewState createState() => _UsersTabViewState();
}

class _UsersTabViewState extends State<UsersTabView>
    with SingleTickerProviderStateMixin {
  int? selectedUserId;
  late TabController _tabController;
  bool isLoading = false;
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Use Future.microtask to fetch both lists simultaneously
    Future.microtask(() async {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      await Future.wait([
        provider.AdminfetchallusersProvider(),
        provider.AdminfetchUnApprovedusersProvider(),
      ]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getApprovedUsers(
      List<dynamic>? allUsers, List<dynamic>? unapprovedUsers) {
    if (allUsers == null) return [];
    if (unapprovedUsers == null) return allUsers;

    // Create a set of unapproved user IDs for efficient lookup
    final unapprovedIds = Set<int>.from(unapprovedUsers.map((u) => u.userId));

    // Filter out users whose IDs are in the unapproved set
    return allUsers
        .where((user) => !unapprovedIds.contains(user.userId))
        .toList();
  }

  Future<void> _handleApproval(int userId, String role, String action) async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await provider.adminApproveUserprovider(
        userId: userId,
        role: role,
        action: action,
      );

      if (mounted) {
        // Refresh both lists after approval/rejection
        await Future.wait([
          provider.AdminfetchallusersProvider(),
          provider.AdminfetchUnApprovedusersProvider(),
        ]);

        _showSnackBar(
            action == 'approve'
                ? 'User approved successfully'
                : 'User deleted successfully',
            isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    if (searchQuery.isEmpty) return users;
    return users.where((user) {
      final query = searchQuery.toLowerCase();
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      final phoneNumber = (user.phoneNumber?.toLowerCase() ?? '');
      final registrationId = (user.registrationId?.toLowerCase() ?? '');

      return name.contains(query) ||
          email.contains(query) ||
          phoneNumber.contains(query) ||
          registrationId.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allUsersProvider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Users Management',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Approved Users'),
            Tab(text: 'Pending Approvals'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: lightBlue,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, color: primaryBlue),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: primaryBlue),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
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
                  borderSide: BorderSide(color: primaryBlue),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Approved Users Tab
                _buildUserList(
                  _getApprovedUsers(
                    allUsersProvider.users,
                    allUsersProvider.unapprovedUsers,
                  ),
                  isLoading,
                  'approved',
                ),
                // Unapproved Users Tab
                _buildUserList(
                  allUsersProvider.unapprovedUsers ?? [],
                  isLoading,
                  'unapproved',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users, bool isLoading, String listType) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'No users available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final filteredUsers = _filterUsers(users);
    if (filteredUsers.isEmpty) {
      return _buildEmptyState(listType);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildExpandableUserCard(user, listType);
      },
    );
  }

  Widget _buildExpandableUserCard(dynamic user, String listType) {
    final isSelected = selectedUserId == user.userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedUserId = null;
            } else {
              selectedUserId = user.userId;
              // Fetch user details when selected
              final provider = Provider.of<AdminAuthProvider>(context, listen: false);
              provider.fetchUserDetails(user.userId);
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? lightBlue.withOpacity(0.3) : Colors.white,
            border: Border.all(
              color: isSelected
                  ? primaryBlue.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // User Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isSelected ? primaryBlue : Colors.grey[300],
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? primaryBlue : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (user.phoneNumber != null &&
                                  user.phoneNumber!.isNotEmpty) ...[
                                Icon(
                                  Icons.phone,
                                  size: 12,
                                  color: isSelected ? primaryBlue : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.phoneNumber!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? primaryBlue : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryBlue.withOpacity(0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? primaryBlue : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (listType == 'unapproved')
                          TextButton(
                            onPressed: () =>
                                _handleApproval(user.userId, user.role, 'approve'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              minimumSize: const Size(80, 40),
                            ),
                            child: const Text('Approve'),
                          ),
                        TextButton(
                          onPressed: () =>
                              _handleApproval(user.userId, user.role, 'reject'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            minimumSize: const Size(80, 40),
                          ),
                          child:
                              Text(listType == 'unapproved' ? 'Reject' : 'Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Expanded Course Details Section
              if (isSelected)
                Consumer<AdminAuthProvider>(
                  builder: (context, provider, child) {
                    final userDetails = provider.user;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.book_outlined,
                                  size: 20, color: primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                'Enrolled Courses',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (userDetails == null)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (userDetails.user.courses.isEmpty)
                            const Text(
                              'No courses enrolled',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: userDetails.user.courses.length,
                              itemBuilder: (context, index) {
                                final course = userDetails.user.courses[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.courseName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (course.batchName != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.group_outlined,
                                                size: 12, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Batch: ${course.batchName}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (course.assignments != null ||
                                          course.quizzes != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (course.assignments != null)
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.assignment_outlined,
                                                        size: 12,
                                                        color: Colors.grey[600]),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Assignments: ${course.assignments!.submittedAssignments}/${course.assignments!.totalAssignments}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (course.quizzes != null)
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.quiz_outlined,
                                                        size: 12,
                                                        color: Colors.grey[600]),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Quizzes: ${course.quizzes!.submittedQuizzes}/${course.quizzes!.totalQuizzes}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String listType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: mediumBlue),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? listType == 'unapproved'
                    ? 'No pending approvals'
                    : 'No approved users found'
                : 'No matching users found',
            style: TextStyle(
              fontSize: 18,
              color: primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
