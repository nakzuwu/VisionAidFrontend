import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vision_aid_app/app/data/services/api_service.dart';
import 'package:vision_aid_app/app/data/model/reminder_model.dart';

class CalendarController extends GetxController {
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  final selectedEvents = <Map<String, dynamic>>[].obs;
  final events = <DateTime, List<Map<String, dynamic>>>{}.obs;
  final storage = GetStorage();

  final List<Reminder> _syncQueue = [];

  Future<void> _processSyncQueue() async {
    for (final reminder in _syncQueue) {
      await ApiService.syncReminder(reminder);
    }
    _syncQueue.clear();
  }

  @override
  void onInit() {
    super.onInit();
    _loadEvents();
    loadEventsFromServer();
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    _updateSelectedEvents(selected);
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  Future<void> loadEventsFromServer() async {
    final reminders = await ApiService.fetchAllReminders();

    final Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};

    for (final reminder in reminders) {
      final dayKey = DateTime(
        reminder.day.year,
        reminder.day.month,
        reminder.day.day,
      );

      final eventMap = {
        'id': reminder.id,
        'title': reminder.title,
        'description': reminder.description,
        'date': reminder.date,
        'time': reminder.time,
        'color': reminder.color, // ✅ Simpan langsung sebagai Color
        'day': reminder.day,
      };

      tempEvents[dayKey] ??= [];
      tempEvents[dayKey]!.add(eventMap);
    }

    events.value = tempEvents;
    _saveEvents();
    _updateSelectedEvents(selectedDay.value);
    focusedDay.refresh();
  }

  void _loadEvents() {
    final stored = storage.read('events');
    if (stored != null) {
      final Map<String, dynamic> decoded = json.decode(stored);
      events.clear();
      decoded.forEach((key, value) {
        final parsedDate = DateTime.parse(key);
        final normalizedKey = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );

        final restoredEvents =
            (value as List).map<Map<String, dynamic>>((event) {
              final rawDay = event['day'];

              final rawColor = event['color'];
              final color =
                  rawColor is String
                      ? Reminder.hexToColor(rawColor)
                      : rawColor is int
                      ? Color(rawColor)
                      : rawColor;

              return {
                ...event,
                'day': rawDay is DateTime ? rawDay : DateTime.parse(rawDay),
                'color': color,
              };
            }).toList();

        events[normalizedKey] = restoredEvents;
      });

      _updateSelectedEvents(selectedDay.value);
    }
  }

  void _saveEvents() {
    final Map<String, dynamic> eventsMap = {};

    events.forEach((date, eventList) {
      final normalizedKey = DateTime(date.year, date.month, date.day);
      final serializedEvents =
          eventList.map((event) {
            final eventCopy = Map<String, dynamic>.from(event);

            final dayVal = eventCopy['day'];
            if (dayVal is DateTime) {
              eventCopy['day'] = dayVal.toIso8601String();
            }

            final colorVal = eventCopy['color'];
            if (colorVal is Color) {
              eventCopy['color'] = Reminder.colorToHex(
                colorVal,
              ); // ✅ ubah jadi HEX
            }

            final reminder = Reminder(
              id: eventCopy['id'],
              title: eventCopy['title'],
              description: eventCopy['description'],
              date: eventCopy['date'],
              time: eventCopy['time'],
              color:
                  colorVal is Color ? colorVal : Reminder.hexToColor(colorVal),
              day: DateTime.parse(eventCopy['day']),
            );

            _syncQueue.add(reminder); // ✅ sinkron nanti
            return eventCopy;
          }).toList();

      eventsMap[normalizedKey.toIso8601String()] = serializedEvents;
    });

    storage.write('events', json.encode(eventsMap));
    _processSyncQueue(); // 🔄 kirim ke server
  }

  Future<void> addEvent(Map<String, dynamic> event) async {
    final rawDay = event['day'];
    final day = rawDay is DateTime ? rawDay : DateTime.parse(rawDay);
    final dayKey = DateTime(day.year, day.month, day.day);

    final eventCopy = Map<String, dynamic>.from(event);
    eventCopy['day'] = day;

    events[dayKey] ??= [];
    events[dayKey]!.add(eventCopy);

    _updateSelectedEvents(selectedDay.value);
    _saveEvents();
    focusedDay.refresh();

    await ApiService.syncReminder(Reminder.fromJson(eventCopy));
  }

  void updateEvent(String id, Map<String, dynamic> updatedEvent) {
    deleteEvent(id);
    addEvent(updatedEvent);
    _saveEvents();
    selectedEvents.refresh();
    focusedDay.refresh();
  }

  void deleteEvent(String id) async {
    events.forEach((key, value) {
      value.removeWhere((event) => event['id'] == id);
    });

    _updateSelectedEvents(selectedDay.value);
    _saveEvents();
    selectedEvents.refresh();
    focusedDay.refresh();

    await ApiService.deleteReminder(id);
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

  Future<void> syncAllRemindersToCloud() async {
    final allEvents = <Map<String, dynamic>>[];
    events.values.forEach(allEvents.addAll);

    for (var event in allEvents) {
      final rawColor = event['color'];
      final color =
          rawColor is Color
              ? rawColor
              : rawColor is int
              ? Color(rawColor)
              : Reminder.hexToColor(rawColor);

      final reminder = Reminder(
        id: event['id'],
        title: event['title'],
        description: event['description'],
        date: event['date'],
        time: event['time'],
        color: color,
        day:
            event['day'] is DateTime
                ? event['day']
                : DateTime.parse(event['day']),
      );

      await ApiService.syncReminder(reminder);
    }
  }
}
