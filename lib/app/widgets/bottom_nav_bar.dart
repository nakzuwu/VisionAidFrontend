import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  Widget buildNavItem({
    required IconData icon,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.yellow[700] : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60, // memberi ruang vertikal yang cukup
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildNavItem(
              icon: Icons.home,
              index: 0,
              onTap: () => Get.toNamed(Routes.HOME),
            ),
            buildNavItem(
              icon: Icons.calendar_today,
              index: 1,
              onTap: () => Get.toNamed(Routes.CALENDAR),
            ),
            const SizedBox(width: 48), // ruang untuk FAB di tengah
            buildNavItem(
              icon: Icons.folder,
              index: 2,
              onTap: () => Get.toNamed(Routes.FOLDER),
            ),
            buildNavItem(
              icon: Icons.settings,
              index: 3,
              onTap: () => Get.toNamed(Routes.SETTING),
            ),
          ],
        ),
      ),
    );
  }
}
