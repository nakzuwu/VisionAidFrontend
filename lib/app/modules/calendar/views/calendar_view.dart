import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import '../controllers/calendar_controller.dart';
import '../../../widgets/bottom_nav_bar.dart';

class CalendarView extends GetView<CalendarController> {
  CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: ()=> Get.toNamed(Routes.NOTE_DETAIL),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              TableCalendar(
                focusedDay: controller.focusedDay.value,
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                selectedDayPredicate:
                    (day) => isSameDay(controller.selectedDay.value, day),
                onDaySelected: (selectedDay, focusedDay) {
                  controller.onDaySelected(selectedDay, focusedDay);
                  _showDayOptions(selectedDay);
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: controller.getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  markersAutoAligned: true,
                  markerSize: 6,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildEventsList()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEventsList() {
    return Obx(() {
      if (controller.selectedEvents.isEmpty) {
        return Center(
          child: Text(
            'No reminders for this day',
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.selectedEvents.length,
        itemBuilder: (_, index) {
          final event = controller.selectedEvents[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: event['color'],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: Text(
                event['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle:
                  event['description'] != null &&
                          event['description'].isNotEmpty
                      ? Text(
                        event['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      )
                      : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event['time'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditReminderDialog(event);
                      } else if (value == 'delete') {
                        _confirmDeleteEvent(event['id']);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showDayOptions(DateTime day) {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Reminder'),
              onTap: () {
                Get.back();
                _showAddReminderDialog(selectedDay: day);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('View ${DateFormat('MMM d, y').format(day)}'),
              onTap: () {
                Get.back();
                controller.onDaySelected(day, day);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void _showAddReminderDialog({DateTime? selectedDay}) {
    final day = selectedDay ?? controller.selectedDay.value;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final timeController = TextEditingController();
    final selectedColor = Colors.blue.obs;

    Get.dialog(
      Obx(
        () => AlertDialog(
          title: Text('Add Reminder for ${DateFormat('MMM d, y').format(day)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (optional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: Get.context!,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      timeController.text = time.format(Get.context!);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Select Color:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildColorOption(Colors.blue, selectedColor),
                    _buildColorOption(Colors.red, selectedColor),
                    _buildColorOption(Colors.green, selectedColor),
                    _buildColorOption(Colors.purple, selectedColor),
                    _buildColorOption(Colors.orange, selectedColor),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Title is required',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                Get.back(); // tutup popup SEBELUM simpan

                final event = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'date': DateFormat('MMM d, y').format(day),
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'time': timeController.text,
                  'color': selectedColor.value,
                  'day': day,
                };

                controller.addEvent(event);

                Future.delayed(const Duration(milliseconds: 300), () {
                  Get.snackbar('Success', 'Reminder added');
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showEditReminderDialog(Map<String, dynamic> event) {
    final day = event['day'] as DateTime;
    final titleController = TextEditingController(text: event['title']);
    final descriptionController = TextEditingController(
      text: event['description'],
    );
    final timeController = TextEditingController(text: event['time']);
    final selectedColor = (event['color'] as Color).obs;

    Get.dialog(
      Obx(
        () => AlertDialog(
          title: Text(
            'Edit Reminder for ${DateFormat('MMM d, y').format(day)}',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (optional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: Get.context!,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      timeController.text = time.format(Get.context!);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Select Color:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildColorOption(Colors.blue, selectedColor),
                    _buildColorOption(Colors.red, selectedColor),
                    _buildColorOption(Colors.green, selectedColor),
                    _buildColorOption(Colors.purple, selectedColor),
                    _buildColorOption(Colors.orange, selectedColor),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Title is required',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                final updatedEvent = {
                  'id': event['id'],
                  'date': DateFormat('MMM d, y').format(day),
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'time': timeController.text,
                  'color': selectedColor.value,
                  'day': day,
                };

                controller.updateEvent(event['id'], updatedEvent);
                Get.back();
                Get.snackbar(
                  'Updated',
                  'Reminder updated',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildColorOption(Color color, Rx<Color> selectedColor) {
    return GestureDetector(
      onTap: () => selectedColor.value = color,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border:
              selectedColor.value == color
                  ? Border.all(color: Colors.black, width: 2)
                  : null,
        ),
      ),
    );
  }

  void _confirmDeleteEvent(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteEvent(id);
              Get.back();
              Get.snackbar(
                'Deleted',
                'Reminder deleted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
