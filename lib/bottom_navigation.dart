import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onListPressed;
  final VoidCallback onLogoutPressed;

  BottomNavigation({
    required this.onProfilePressed,
    required this.onListPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Scaffold(
          body: const Placeholder(),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Tela 1',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.more),
                label: 'Tela 2',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: onLogoutPressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.logout),
                  ),
                ),
                label: 'Logout',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                onProfilePressed();
              } else if (index == 1) {
                onListPressed();
              }
            },
          ),
        ),
      ),
    );
  }
}
