import 'package:flutter/material.dart';
import 'package:lms/screens/admin/course_management/admin_add_course.dart';
import 'package:lms/screens/admin/course_management/admin_see_allstudent.dart';
import 'package:lms/screens/admin/course_management/admin_student.dart';
import 'package:lms/screens/admin/widgets/bottom.dart';
import 'package:lms/screens/admin/widgets/mainmenu.dart';
import 'package:lms/screens/admin/widgets/searchfiled.dart';
import 'package:lms/screens/admin/widgets/usercard.dart';


class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedContent = 'Dashboard';
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void updateContent(String newContent) {
    setState(() {
      selectedContent = newContent;
    });
  }

  void handleMenuSelection(String value) {
    if (value == 'Settings') {
      updateContent('Settings');
    } else if (value == 'Sign Out') {
    }
  }



  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: Text('Dashboard'),
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: handleMenuSelection,
                  itemBuilder: (context) {
                    return {'Settings', 'Sign Out'}.map((choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              child: Sidebar(
                isLargeScreen: isLargeScreen,
                onMenuItemSelected: updateContent,
                searchController: searchController,
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (isLargeScreen)
                Sidebar(
                  isLargeScreen: isLargeScreen,
                  onMenuItemSelected: updateContent,
                  searchController: searchController,
                ),
              Expanded(
                child: ContentArea(
                  isLargeScreen: isLargeScreen,
                  selectedContent: selectedContent,
                  searchController: searchController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class Sidebar extends StatelessWidget {
  final Function(String) onMenuItemSelected;
  final TextEditingController searchController;
  final bool isLargeScreen;

  Sidebar({
    required this.onMenuItemSelected,
    required this.searchController,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isLargeScreen ? 300.0 : MediaQuery.of(context).size.width * 0.8;

    return Card(
      elevation: 4,
      child: Container(
        color: Colors.white,
        width: sidebarWidth,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminUserCard(userId: 'userId'),
                    const SizedBox(height: 20),
                    AdminSearchField(searchController: searchController),
                    const SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: AdminMainMenu(
                        isLargeScreen: isLargeScreen,
                        onMenuItemSelected: onMenuItemSelected,
                      ),
                    ),
                    const SizedBox(height: 90),
                    Divider(),
                    AdminBottom(
                      onMenuItemSelected: onMenuItemSelected,
                      isLargeScreen: isLargeScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}











class ContentArea extends StatelessWidget {
  final String selectedContent;
  final TextEditingController searchController;
  final bool isLargeScreen;  // Accepting isLargeScreen

  const ContentArea({required this.selectedContent, required this.searchController, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          
          Expanded(child: _buildContent(selectedContent)),
        ],
      ),
    );
  }

  Widget _buildContent(String selectedContent) {
    switch (selectedContent) {
      case 'Course Content':
        return AdminAddCourse();

         case 'Course Management':
        return AdminAddCourse();
      
      case 'Students Manager':
        return AdminAddStudent();
        case 'Our Centers':
        return AllUsersPage();
      case 'live':
        return AdminAddCourse();
      case 'Dashboard':
        return AdminAddCourse();
      default:
        return AdminAddCourse();
    }
  }
}


