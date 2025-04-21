import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
  Rx<DateTime> selectedDay = DateTime.now().obs;
  Rx<DateTime> focusedDay = DateTime.now().obs;

  final RxList<Map<String, dynamic>> selectedEvents = <Map<String, dynamic>>[].obs;

  final List<Map<String, dynamic>> allEvents = [
    {
      'date': DateTime(2021, 2, 17),
      'title': 'Ulangan Matematika',
      'color': Colors.blue,
    },
    {
      'date': DateTime(2021, 2, 24),
      'title': 'Tes Toefl Bahasa Inggris',
      'color': Colors.green,
    },
  ];

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return allEvents.where((event) => isSameDay(event['date'], day)).toList();
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    selectedEvents.value = getEventsForDay(selected);
  }

  @override
  void onInit() {
    selectedEvents.value = getEventsForDay(selectedDay.value);
    super.onInit();
  }
}
