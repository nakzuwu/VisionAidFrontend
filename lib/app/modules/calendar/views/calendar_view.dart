import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/calendar_controller.dart';
import '../../../widgets/bottom_nav_bar.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () {},
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
                selectedDayPredicate: (day) => isSameDay(controller.selectedDay.value, day),
                onDaySelected: controller.onDaySelected,
                calendarFormat: CalendarFormat.month,
                eventLoader: controller.getEventsForDay,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.selectedEvents.length,
                  itemBuilder: (_, index) {
                    final event = controller.selectedEvents[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: event['color'],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${event['date']} - ${event['title']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
