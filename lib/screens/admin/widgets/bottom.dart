import 'package:flutter/material.dart';
import 'package:lms/screens/admin/widgets/sidebarbutton.dart';

class AdminBottom extends StatefulWidget {
  final Function(String) onMenuItemSelected;
  final bool isLargeScreen;

  const AdminBottom({
    Key? key,
    required this.onMenuItemSelected,
    required this.isLargeScreen,
  }) : super(key: key);

  @override
  _BottomState createState() => _BottomState();
}

class _BottomState extends State<AdminBottom> {
  String selectedMenu = '';
  bool isLoading = false;

  void updateSelectedMenu(String newMenu) {
    setState(() {
      selectedMenu = newMenu;
    });
    widget.onMenuItemSelected(newMenu);
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         
          AdminSidebarButton(
            icon: Icons.logout,
            text: isLoading ? 'Logging out...' : 'Log out',
            isSelected: selectedMenu == 'Log out',
            onTap: () =>isLoading  // Fixed: Properly calling _logout with context
          ),
        ],
      ),
    );
  }
}