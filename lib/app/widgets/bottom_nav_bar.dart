import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Custom HOME Button
            GestureDetector(
              onTap: () => Get.toNamed(Routes.HOME),
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow[700],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 28),
                ),
              ),
            ),
            // Calendar
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                size: currentIndex == 1 ? 30 : 26,
                weight: currentIndex == 1 ? 800 : 400,
              ),
              onPressed: () => Get.toNamed(Routes.CALENDAR),
              color: Colors.grey,
            ),
            const SizedBox(width: 48),
            // Folder
            IconButton(
              icon: Icon(
                Icons.folder,
                size: currentIndex == 2 ? 30 : 26,
                weight: currentIndex == 2 ? 800 : 400,
              ),
              onPressed: () => Get.toNamed(Routes.FOLDER),
              color: Colors.grey,
            ),
            // Settings
            IconButton(
              icon: Icon(
                Icons.settings,
                size: currentIndex == 3 ? 30 : 26,
                weight: currentIndex == 3 ? 800 : 400,
              ),
              onPressed: () => Get.toNamed(Routes.SETTING),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
