import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vision_aid_app/app/data/model/note_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vision_aid_app/app/data/services/api_service.dart';
import 'package:vision_aid_app/app/modules/folder/controllers/folder_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vision_aid_app/app/modules/home/controllers/home_controller.dart';

class NoteDetailController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxInt currentIndex = 0.obs;
  final RxString selectedFolder = 'Default'.obs;
  final RxList<String> images = <String>[].obs;
  final RxList<String> remoteImages = <String>[].obs;
  final notes = <Note>[].obs;
  final storage = GetStorage();
  final uuid = const Uuid();
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final selectedText = ''.obs;
  final TextEditingController summaryController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final showPreview = false.obs;
  String? noteId;
  bool isNewNote = false;

  @override
  void onInit() {
    super.onInit();
    _resetControllerState();

    final dynamic args = Get.arguments;
    noteId = _parseNoteId(args);

    if (noteId != null && noteId!.isNotEmpty) {
      loadNote();
    } else {
      isNewNote = true;
    }

    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      isOnline.value = result != ConnectivityResult.none;
      if (isOnline.value) _syncNotes();
    });
  }

  String? _parseNoteId(dynamic args) {
    if (args == null) return null;
    if (args is String) return args;
    if (args is Map) return args['noteId']?.toString();
    return null;
  }

  void _resetControllerState() {
    textController.clear();
    images.clear();
    remoteImages.clear();
    selectedFolder.value = 'Default';
    currentIndex.value = 0;
  }

  void saveNoteLocally() {
    if (noteId == null || noteId!.isEmpty) {
      noteId = uuid.v4();
    }

    final String id = noteId!;

    if (textController.text.trim().isEmpty && images.isEmpty) {
      return;
    }

    final now = DateTime.now();

    final note = Note(
      id: id,
      title: _getNoteTitle(),
      content: textController.text,
      folder: selectedFolder.value,
      createdAt:
          (storage.read(id)?['created_at'] != null)
              ? DateTime.parse(storage.read(id)['created_at'])
              : now,
      updatedAt: now,
      images: [...images, ...remoteImages],
      isSynced: false,
      lastOpened: now,
    );

    storage.write(id, note.toJson());

    final folders = storage.read('folders') ?? {};
    if (!folders.containsKey(note.folder)) {
      folders[note.folder] = [];
    }

    final List<dynamic> folderNotes = folders[note.folder];
    if (!folderNotes.contains(id)) {
      folderNotes.add(id);
    }

    storage.write('folders', folders);
    final existingIndex = notes.indexWhere((n) => n.id == id);
    if (existingIndex != -1) {
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.refreshRecentNotes();
    }

    if (isOnline.value) {
      _syncNoteToServer(note);
    }

    // Get.snackbar('Saved', 'Note saved to ${note.folder}');

    if (Get.isRegistered<FolderController>()) {
      final folderController = Get.find<FolderController>();
      folderController.refreshFolders();
    }

    if (isNewNote) {
      isNewNote = false;
      Get.offNamed(Get.currentRoute, arguments: id, preventDuplicates: false);
    }
  }

  TextSpan parseRichText(String input) {
    final List<TextSpan> spans = [];

    final pattern = RegExp(
      r'(\*\*(.*?)\*\*|__([^_]+)__|~~(.*?)~~|- (.*?)\n?|==(.*?)==)',
      dotAll: true,
    );

    int lastMatchEnd = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: input.substring(lastMatchEnd, match.start)));
      }

      final bold = match.group(2);
      final italic = match.group(3);
      final strike = match.group(4);
      final listItem = match.group(5);
      final highlight = match.group(6);

      if (bold != null) {
        spans.add(
          TextSpan(
            text: bold,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (italic != null) {
        spans.add(
          TextSpan(
            text: italic,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (strike != null) {
        spans.add(
          TextSpan(
            text: strike,
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
        );
      } else if (listItem != null) {
        spans.add(TextSpan(text: '• $listItem\n'));
      } else if (highlight != null) {
        spans.add(
          TextSpan(
            text: highlight,
            style: const TextStyle(backgroundColor: Colors.yellow),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastMatchEnd)));
    }

    return TextSpan(
      children: spans,
      style: const TextStyle(color: Colors.black),
    );
  }

  void insertFormat(String prefix, String suffix) {
    final text = textController.text;
    final selection = textController.selection;

    final start = selection.start;
    final end = selection.end;

    final selected =
        start >= 0 && end >= 0 && start != end
            ? text.substring(start, end)
            : 'teks';

    final newText = text.replaceRange(start, end, '$prefix$selected$suffix');

    textController.value = textController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            start +
            prefix.length +
            selected.length +
            suffix.length -
            suffix.length,
      ),
    );
  }

  void insertListItem() {
    final text = textController.text;
    final selection = textController.selection;

    final insertion = '- ';
    final start = selection.start;

    final newText = text.replaceRange(start, start, insertion);

    textController.value = textController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
  }

  Future<void> summarizeAndReplace() async {
    final fullText = textController.text.trim();
    if (fullText.isEmpty) {
      Get.snackbar('Gagal', 'Catatan kosong');
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final summary = await summarizeText(fullText);
    Get.back();

    if (summary != null) {
      textController.text = summary;
    } else {
      Get.snackbar('Gagal', 'Gagal merangkum catatan');
    }
  }

  var allNotes = <Note>[].obs;

  void loadAllNotes() {
    final keys = GetStorage().getKeys();
    allNotes.value =
        keys
            .map((key) {
              final raw = GetStorage().read(key);
              if (raw is Map) {
                return Note.fromMap(Map<String, dynamic>.from(raw));
              }
              return null;
            })
            .whereType<Note>()
            .toList();
  }

  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isOnline.value = connectivityResult != ConnectivityResult.none;
  }

  void loadNote() {
    if (noteId == null || noteId!.isEmpty) return;

    final String id = noteId!;
    final noteData = storage.read(id);

    if (noteData != null) {
      final note = Note.fromJson(noteData);
      final updated = note.copyWith(lastOpened: DateTime.now());
      storage.write(note.id, updated.toJson());

      _populateNote(updated);
      _refreshHomeRecentNotes();
    } else {
      Get.snackbar('Error', 'Note tidak ditemukan');
    }
  }

  void _refreshHomeRecentNotes() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      await Future.delayed(const Duration(milliseconds: 300));

      homeController.refreshRecentNotes();
    }
  }

  void _populateNote(Note note) {
    textController.text = note.content;
    selectedFolder.value = note.folder;
    images.value = note.images.where((img) => img.startsWith('/')).toList();
    remoteImages.value =
        note.images.where((img) => !img.startsWith('/')).toList();
  }

  void openNote(String id) {
    final data = GetStorage().read(id);
    if (data != null) {
      final note = Note.fromMap(Map<String, dynamic>.from(data));
      final updated = note.copyWith(lastOpened: DateTime.now());
      GetStorage().write(id, updated.toJson());
    }
  }

  Future<void> _syncNoteToServer(Note note) async {
    try {
      final success = await ApiService.syncNote(note);
      if (!success) {
        Get.snackbar('Sync Gagal', 'Gagal sinkron ke server');
        return;
      }

      final updatedNote = note.copyWith(isSynced: true);
      storage.write(updatedNote.id, updatedNote.toJson());

      for (final imagePath in note.images) {
        if (imagePath.startsWith('/')) {
          await _uploadImage(updatedNote.id, imagePath);
        }
      }

      // Get.snackbar('Sinkron Berhasil', 'Catatan disimpan di server');
    } catch (e) {
      Get.snackbar('Sync Error', 'Gagal sync ke server: $e');
    }
  }

  Future<void> fetchNotesFromCloud() async {
    if (!isOnline.value) return;

    try {
      isLoading.value = true;
      final notesData = await ApiService.fetchAllNotes();

      for (var item in notesData) {
        final note = item;

        storage.write(note.id, note.toJson());

        final index = notes.indexWhere((n) => n.id == note.id);
        if (index == -1) {
          notes.add(note);
        } else {
          notes[index] = note;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil catatan dari server');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _uploadImage(String noteId, String imagePath) async {
    try {
      final imageUrl = await ApiService.uploadImage(noteId, imagePath);
      if (imageUrl != null) {
        final note = Note.fromJson(storage.read(noteId));
        final updatedImages =
            [...note.images]
              ..remove(imagePath)
              ..add(imageUrl);
        final updatedNote = note.copyWith(images: updatedImages);
        storage.write(noteId, updatedNote.toJson());
      }
    } catch (e) {
      Get.snackbar('Upload Error', 'Failed to upload image');
    }
  }

  Future<String?> summarizeText(String text) async {
    final response = await ApiService().summarizeText(text);
    if (response != null && response['summary'] != null) {
      return response['summary'];
    }
    return null;
  }

  void insertSummary(String summary) {
    final text = textController.text;
    final selection = textController.selection;
    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);
    textController.text = '$before$summary$after';
  }

  Future<void> _syncNotes() async {
    loadAllNotes();
    final unsyncedNotes = allNotes.where((note) => !note.isSynced).toList();
    for (final note in unsyncedNotes) {
      await _syncNoteToServer(note);
    }
  }

  List<String> get folderList {
    final folders = storage.read('folders') ?? {};
    return folders.keys.cast<String>().toList();
  }

  void applyBoldFormat() {
    final selection = textController.selection;
    final text = textController.text;
    final selectedText = text.substring(selection.start, selection.end);

    if (selectedText.isNotEmpty) {
      final formattedText = '*$selectedText*';
      textController.text = text.replaceRange(
        selection.start,
        selection.end,
        formattedText,
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start,
        extentOffset: selection.start + formattedText.length,
      );
    } else {
      textController.text = text.replaceRange(
        selection.start,
        selection.start,
        '**',
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start + 1,
        extentOffset: selection.start + 1,
      );
    }
  }

  void applyItalicFormat() {
    final selection = textController.selection;
    final text = textController.text;
    final selectedText = text.substring(selection.start, selection.end);

    if (selectedText.isNotEmpty) {
      final formattedText = '_${selectedText}_';
      textController.text = text.replaceRange(
        selection.start,
        selection.end,
        formattedText,
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start,
        extentOffset: selection.start + formattedText.length,
      );
    } else {
      textController.text = text.replaceRange(
        selection.start,
        selection.start,
        '__',
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start + 1,
        extentOffset: selection.start + 1,
      );
    }
  }

  void applyStrikethroughFormat() {
    final selection = textController.selection;
    final text = textController.text;
    final selectedText = text.substring(selection.start, selection.end);

    if (selectedText.isNotEmpty) {
      final formattedText = '~$selectedText~';
      textController.text = text.replaceRange(
        selection.start,
        selection.end,
        formattedText,
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start,
        extentOffset: selection.start + formattedText.length,
      );
    } else {
      textController.text = text.replaceRange(
        selection.start,
        selection.start,
        '~~',
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start + 1,
        extentOffset: selection.start + 1,
      );
    }
  }

  void addNumberedList() {
    final selection = textController.selection;
    final text = textController.text;

    final preText = text.substring(0, selection.start);
    final lastNewLine = preText.lastIndexOf('\n');
    final currentLineStart = lastNewLine == -1 ? 0 : lastNewLine + 1;
    final currentLine = text.substring(currentLineStart, selection.start);

    if (currentLine.isEmpty || currentLine.startsWith(RegExp(r'\d+\.\s'))) {
      final listItem = '1. ';
      textController.text = text.replaceRange(
        selection.start,
        selection.start,
        listItem,
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start + listItem.length,
        extentOffset: selection.start + listItem.length,
      );
    } else {
      final listItem = '\n1. ';
      textController.text = text.replaceRange(
        selection.start,
        selection.start,
        listItem,
      );
      textController.selection = selection.copyWith(
        baseOffset: selection.start + listItem.length,
        extentOffset: selection.start + listItem.length,
      );
    }
  }

  final List<BottomNavigationBarItem> bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.format_bold), label: 'Bold'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.format_italic),
      label: 'Italic',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.strikethrough_s),
      label: 'Strike',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.format_list_numbered),
      label: 'List',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Image'),
  ];

  @override
  void onClose() {
    saveNoteLocally();
    textController.dispose();
    summaryController.dispose();
    _refreshHomeRecentNotes();

    if (_recorder.isRecording) {
      _recorder.stopRecorder();
    }

    Get.delete<NoteDetailController>(force: true);
    super.onClose();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        applyBoldFormat();
        break;
      case 1:
        applyItalicFormat();
        break;
      case 2:
        applyStrikethroughFormat();
        break;
      case 3:
        addNumberedList();
        break;
      case 4:
        pickImage();
        break;
    }
    Future.delayed(
      const Duration(milliseconds: 300),
      () => currentIndex.value = 0,
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imagePath = pickedFile.path;
      images.add(imagePath);

      final selection = textController.selection;
      final text = textController.text;
      textController.text =
          '${text.substring(0, selection.start)}\n[image:$imagePath]\n${text.substring(selection.start)}';
      textController.selection = selection.copyWith(
        baseOffset: selection.start + 14 + imagePath.length,
        extentOffset: selection.start + 14 + imagePath.length,
      );
    }
  }

  String _getNoteTitle() {
    final content = textController.text;
    if (content.isEmpty) return 'Untitled Note';

    final firstLineEnd = content.indexOf('\n');
    if (firstLineEnd == -1) {
      return content.length > 30 ? '${content.substring(0, 30)}...' : content;
    }

    return content.substring(0, firstLineEnd > 30 ? 30 : firstLineEnd);
  }

  Future<void> pickImageForOCR() async {
    final picker = ImagePicker();

    final source = await Get.bottomSheet<ImageSource>(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text("Ambil Foto"),
            onTap: () => Get.back(result: ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Pilih dari Galeri"),
            onTap: () => Get.back(result: ImageSource.gallery),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    await processOCR(file);
  }

  Future<void> processOCR(File imageFile) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final apiKey = storage.read('api_key') ?? '';
      if (apiKey.isEmpty) {
        Get.back();
        Get.snackbar('Gagal', 'API Key tidak ditemukan');
        return;
      }

      final response = await ApiService().uploadOCRImage(imageFile, apiKey);
      Get.back();

      if (response == null || response['text'] == null) {
        Get.snackbar('Gagal', 'Gagal memproses OCR');
        return;
      }

      final extractedText = response['text'];
      final controller = TextEditingController(text: extractedText);

      Get.defaultDialog(
        title: 'Hasil OCR',
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Hasil OCR...',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final noteController = Get.find<NoteDetailController>();
                  final ocrText = controller.text.trim();

                  final selection = noteController.textController.selection;
                  final oldText = noteController.textController.text;

                  final safeStart = selection.start.clamp(0, oldText.length);
                  final safeEnd = selection.end.clamp(0, oldText.length);

                  final newText = oldText.replaceRange(
                    safeStart,
                    safeEnd,
                    '\n$ocrText\n',
                  );

                  noteController.textController.text = newText;
                  noteController
                      .textController
                      .selection = TextSelection.collapsed(
                    offset: safeStart + ocrText.length + 2,
                  );

                  Get.back();
                },
                child: const Text('Gunakan Hasil'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Terjadi kesalahan saat OCR');
    }
  }

  Future<void> showAudioOptions() async {
    await Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text("Rekam Audio"),
            onTap: () {
              Get.back();
              recordAudio();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text("Pilih File Audio"),
            onTap: () {
              Get.back();
              pickAudioFile();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<void> recordAudio() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/temp_record.wav';

    final allowed = await requestMicPermission();
    if (!allowed) {
      Get.snackbar('Izin ditolak', 'Mikrofon dibutuhkan untuk merekam');
      return;
    }

    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);

    Get.dialog(
      AlertDialog(
        title: const Text('Merekam Audio'),
        content: const Text('Audio sedang direkam...'),
        actions: [
          TextButton(
            onPressed: () async {
              await _recorder.stopRecorder();
              await _recorder.closeRecorder();
              Get.back();
              await _uploadAndShow(File(path));
            },
            child: const Text('Stop'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'm4a'],
    );
    if (result != null && result.files.single.path != null) {
      await _uploadAndShow(File(result.files.single.path!));
    }
  }

  Future<void> _uploadAndShow(File file) async {
    final result = await ApiService().uploadAudio(file);
    if (result != null) {
      try {
        final data = jsonDecode(result);
        if (data['transcript'] != null) {
          textController.text += '\n${data['transcript']}\n';
          // Get.snackbar('Berhasil', 'Audio berhasil ditranskripsi');
        } else {
          Get.snackbar('Gagal', 'Transkripsi tidak ditemukan');
        }
      } catch (e) {
        Get.snackbar('Error', 'Gagal membaca hasil transkripsi');
      }
    }
  }

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}
