import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class CalendarController extends GetxController {
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  final selectedEvents = <Map<String, dynamic>>[].obs;
  final events = <DateTime, List<Map<String, dynamic>>>{}.obs;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadEvents(); // ⬅️ Load dari storage saat controller dibuat
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    this.selectedDay.value = selectedDay;
    this.focusedDay.value = focusedDay;
    _updateSelectedEvents(selectedDay);
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  void _loadEvents() {
    final stored = storage.read('events');
    if (stored != null) {
      final Map<String, dynamic> decoded = json.decode(stored);

      events.clear();
      decoded.forEach((key, value) {
        final parsed = DateTime.parse(key);
        final normalizedKey = DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
        ); // ✅ normalize!

        final restoredEvents =
            (value as List).map<Map<String, dynamic>>((event) {
              final rawDay = event['day'];
              return {
                ...event,
                'day': rawDay is DateTime ? rawDay : DateTime.parse(rawDay),
              };
            }).toList();

        events[normalizedKey] = restoredEvents; // ✅ pakai normalizedKey
      });

      _updateSelectedEvents(selectedDay.value);
    }
  }

  void _saveEvents() {
    final Map<String, dynamic> eventsMap = {};
    events.forEach((date, eventList) {
      final normalizedKey = DateTime(
        date.year,
        date.month,
        date.day,
      ); // ✅ normalize

      final serializedEvents =
          eventList.map((event) {
            final eventCopy = Map<String, dynamic>.from(event);
            final dayVal = eventCopy['day'];
            if (dayVal is DateTime) {
              eventCopy['day'] = dayVal.toIso8601String();
            }
            return eventCopy;
          }).toList();

      eventsMap[normalizedKey.toIso8601String()] = serializedEvents;
    });

    storage.write('events', json.encode(eventsMap));
  }

  void addEvent(Map<String, dynamic> event) {
    final rawDay = event['day'];
    final day = rawDay is DateTime ? rawDay : DateTime.parse(rawDay);
    final dayKey = DateTime(day.year, day.month, day.day); // ✅ normalize

    final eventCopy = Map<String, dynamic>.from(event);
    eventCopy['day'] = day;

    events[dayKey] ??= [];
    events[dayKey]!.add(eventCopy);

    _updateSelectedEvents(selectedDay.value);
    _saveEvents();
  }

  void updateEvent(String id, Map<String, dynamic> updatedEvent) {
    deleteEvent(id);
    addEvent(updatedEvent);
    _saveEvents();
    selectedEvents.refresh();
  }

  void deleteEvent(String id) {
    events.forEach((key, value) {
      value.removeWhere((event) => event['id'] == id);
    });
    _updateSelectedEvents(selectedDay.value);
    _saveEvents();
    selectedEvents.refresh();
  }

  void _updateSelectedEvents(DateTime day) {
    selectedEvents.value = getEventsForDay(day);
    selectedEvents.refresh();
  }

  List<Map<String, dynamic>> get upcomingReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final allEvents = <Map<String, dynamic>>[];
    events.values.forEach(allEvents.addAll);

    return allEvents.where((event) {
        final rawDay = event['day'];
        final eventDate =
            rawDay is DateTime ? rawDay : DateTime.tryParse(rawDay.toString());

        if (eventDate == null) return false;

        final eventDay = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
        );

        return eventDay.isAtSameMomentAs(today) ||
            eventDay.isAtSameMomentAs(tomorrow);
      }).toList()
      ..sort((a, b) {
        final aDate =
            a['day'] is DateTime
                ? a['day']
                : DateTime.tryParse(a['day'].toString()) ?? DateTime.now();
        final bDate =
            b['day'] is DateTime
                ? b['day']
                : DateTime.tryParse(b['day'].toString()) ?? DateTime.now();

        return aDate.compareTo(bDate);
      });
  }
}
