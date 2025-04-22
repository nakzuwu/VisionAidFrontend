import 'package:get/get.dart';

class FolderController extends GetxController {
  var folders = <FolderModel>[
    FolderModel(
      title: 'Matematika',
      isExpanded: false,
      notes: [
        NoteModel(
          title: 'Aljabar',
          time: '13:00',
          date: '3/5/2025',
          content: 'Lorem ipsum dolor sit amet...',
        ),
      ],
    ),
    FolderModel(
      title: 'Bahasa Inggris',
      isExpanded: false,
      notes: [
        NoteModel(
          title: 'Tenses',
          time: '10:00',
          date: '1/4/2025',
          content: 'Simple present tense adalah...',
        ),
      ],
    ),
    FolderModel(
      title: 'Bahasa Jepang',
      isExpanded: false,
      notes: [
        NoteModel(
          title: 'Hiragana',
          time: '09:00',
          date: '2/4/2025',
          content: 'あ、い、う、え、お...',
        ),
      ],
    ),
  ].obs;
}

class FolderModel {
  String title;
  bool isExpanded;
  List<NoteModel> notes;

  FolderModel({required this.title, required this.isExpanded, required this.notes});
}

class NoteModel {
  String title;
  String time;
  String date;
  String content;

  NoteModel({required this.title, required this.time, required this.date, required this.content});
}
