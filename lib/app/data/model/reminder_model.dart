import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final Color color;
  final DateTime day;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.color,
    required this.day,
  });
  static Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date,
    'time': time,
    'color': '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
    'day': day.toIso8601String(),
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  static Reminder fromJson(Map<String, dynamic> json) {
    final rawColor = json['color'];
    final color = rawColor is String ? hexToColor(rawColor) : Color(rawColor);

    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      time: json['time'],
      color: color, // ✅ sudah dipastikan Color
      day: DateTime.parse(json['day']),
    );
  }
}
