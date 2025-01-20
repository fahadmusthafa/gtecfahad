import 'package:flutter/material.dart';

class AdminSidebarButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isSelected;

  AdminSidebarButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius:
              BorderRadius.circular(10), // Applies circular border to all sides
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.blueGrey,
          ),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.blueGrey,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}