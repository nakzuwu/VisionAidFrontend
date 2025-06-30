import 'package:flutter/material.dart';
import 'package:vision_aid_app/app/data/model/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        note.content.length > 100 ? "${note.content.substring(0, 100)}..." : note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // Bisa diarahkan ke detail edit
      },
    );
  }
}
