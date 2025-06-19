import 'package:get/get.dart';

class CalendarController extends GetxController {
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  final selectedEvents = <Map<String, dynamic>>[].obs;
  final events = <DateTime, List<Map<String, dynamic>>>{}.obs;

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    this.selectedDay.value = selectedDay;
    this.focusedDay.value = focusedDay;
    _updateSelectedEvents(selectedDay);
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void addEvent(Map<String, dynamic> event) {
    final day = event['day'] as DateTime;
    final dayKey = DateTime(day.year, day.month, day.day);

    events[dayKey] ??= [];
    events[dayKey]!.add(event);
    _updateSelectedEvents(selectedDay.value);
  }

  void updateEvent(String id, Map<String, dynamic> updatedEvent) {
    // Find and remove the old event
    deleteEvent(id);
    
    // Add the updated event
    addEvent(updatedEvent);
  }

  void deleteEvent(String id) {
    events.forEach((key, value) {
      value.removeWhere((event) => event['id'] == id);
    });
    _updateSelectedEvents(selectedDay.value);
  }

  void _updateSelectedEvents(DateTime day) {
    selectedEvents.value = getEventsForDay(day);
  }
  
  List<Map<String, dynamic>> get upcomingReminders {
    final now = DateTime.now();
    final endTime = now.add(const Duration(days: 1));
    
    // Flatten all events
    final allEvents = <Map<String, dynamic>>[];
    events.values.forEach(allEvents.addAll);
    
    return allEvents.where((event) {
      final eventDate = event['day'] as DateTime?;
      if (eventDate == null) return false;
      
      // Compare without time
      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      // Return true if event is today or tomorrow
      return eventDay.isAtSameMomentAs(today) || 
             eventDay.isAtSameMomentAs(tomorrow);
    }).toList()
      ..sort((a, b) {
        final aDate = a['day'] as DateTime;
        final bDate = b['day'] as DateTime;
        return aDate.compareTo(bDate);
      });
  }
}