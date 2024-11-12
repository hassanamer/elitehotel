import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SideMenu extends StatelessWidget {
  final Function(int) onItemTapped;
  final List<int> visiblePages;

  SideMenu({required this.onItemTapped, required this.visiblePages});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(),
        Expanded(
          child: ListView(
            children: <Widget>[
              if (visiblePages.contains(0)) _buildMenuItem(Icons.dashboard, 'Dashboard', 0),
              if (visiblePages.contains(1)) _buildMenuItem(Icons.front_hand, 'Front Desk', 1),
              if (visiblePages.contains(2)) _buildMenuItem(Icons.cleaning_services, 'Housekeeping', 2),
              if (visiblePages.contains(3)) _buildMenuItem(Icons.people, 'Guest', 3),
              if (visiblePages.contains(4)) _buildMenuItem(Icons.room, 'Rooms', 4),
              if (visiblePages.contains(5)) _buildMenuItem(Icons.rate_review, 'Rates', 5),
              if (visiblePages.contains(6)) _buildMenuItem(Icons.book, 'Reservations', 6),
              if (visiblePages.contains(7)) _buildMenuItem(Icons.book, 'Invoices', 7),
              if (visiblePages.contains(8)) _buildMenuItem(Icons.settings, 'Settings', 8),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color:  Color(0xFFDBB017)),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFDBB017)),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int pageIndex) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFDBB017)),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: () {
        final indexInVisiblePages = visiblePages.indexOf(pageIndex);
        if (indexInVisiblePages != -1) {
          onItemTapped(indexInVisiblePages); // Pass the mapped index
        }
      },
    );
  }
}