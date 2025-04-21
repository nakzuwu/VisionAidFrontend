import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.toNamed(Routes.HOME),
            color: currentIndex == 0 ? Colors.yellow : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Get.toNamed(Routes.CALENDAR),
            color: currentIndex == 1 ? Colors.yellow : Colors.grey,
          ),
          const SizedBox(width: 48), // untuk FAB space
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
    );
  }
}
