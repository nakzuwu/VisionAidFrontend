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
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  String? noteId;
  NoteDetailController({this.noteId});

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      isOnline.value = result != ConnectivityResult.none;
      if (isOnline.value) _syncNotes();
    });

    if (noteId != null) {
      loadNote();
    }
  }

  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isOnline.value = connectivityResult != ConnectivityResult.none;
  }

  void loadNote() {
    final noteData = storage.read(noteId!);
    if (noteData != null) {
      final note = Note.fromJson(noteData);
      _populateNote(note);
    } else {
      Get.snackbar('Error', 'Note tidak ditemukan');
    }
  }

  void _populateNote(Note note) {
    textController.text = note.content;
    selectedFolder.value = note.folder;
    images.value = note.images.where((img) => img.startsWith('/')).toList();
    remoteImages.value =
        note.images.where((img) => !img.startsWith('/')).toList();
  }

  Future<void> fetchNoteFromServer() async {
    if (!isOnline.value) return;

    try {
      isLoading.value = true;
      final note = await ApiService.fetchNote(noteId!);
      if (note != null) {
        _populateNote(note);
        saveNoteLocally(); // Save after fetching
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load note from server');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncNoteToServer(Note note) async {
    try {
      final success = await ApiService.syncNote(note);
      if (success) {
        final updatedNote = note.copyWith(isSynced: true);
        storage.write(updatedNote.id, updatedNote.toJson());

        for (final imagePath in images) {
          await _uploadImage(updatedNote.id, imagePath);
        }
      }
    } catch (e) {
      Get.snackbar('Sync Error', 'Failed to sync note to server');
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

  final apiService = ApiService();

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
    final unsyncedNotes = notes.where((note) => !note.isSynced).toList();
    for (final note in unsyncedNotes) {
      await _syncNoteToServer(note);
    }
  }

  List<String> get folderList {
    final folders = storage.read('folders') ?? {};
    return folders.keys.cast<String>().toList();
  }

  // WhatsApp-like formatting functions
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
      // Insert bold markers at cursor position
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

  void saveNoteLocally() {
    final id = noteId ?? uuid.v4();

    // Kalau sedang membuat catatan baru, simpan ID-nya ke controller agar tidak duplikat
    if (noteId == null) {
      Get.find<NoteDetailController>().noteId = id;
    }

    final note = Note(
      id: id,
      title: _getNoteTitle(),
      content: textController.text,
      folder: selectedFolder.value,
      createdAt:
          (storage.read(id)?['created_at'] != null)
              ? DateTime.parse(storage.read(id)['created_at'])
              : DateTime.now(),
      updatedAt: DateTime.now(),
      images: [...images, ...remoteImages],
      isSynced: false,
      lastOpened: DateTime.now(),
    );

    storage.write(id, note.toJson());

    // Update folder
    final folders = storage.read('folders') ?? {};
    if (!folders.containsKey(note.folder)) {
      folders[note.folder] = [];
    }

    final List<dynamic> folderNotes = folders[note.folder];
    if (!folderNotes.contains(id)) {
      folderNotes.add(id);
    }

    storage.write('folders', folders);

    // Update local list
    final existingIndex = notes.indexWhere((n) => n.id == id);
    if (existingIndex != -1) {
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }

    // Sync
    if (isOnline.value) {
      _syncNoteToServer(note);
    }

    Get.snackbar('Saved', 'Note saved to ${note.folder}');

    if (Get.isRegistered<FolderController>()) {
      final folderController = Get.find<FolderController>();
      final updatedFolders = storage.read('folders') ?? {};
      folderController.folders.assignAll(updatedFolders);
      folderController.folders.refresh();
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

    // Find current line
    final preText = text.substring(0, selection.start);
    final lastNewLine = preText.lastIndexOf('\n');
    final currentLineStart = lastNewLine == -1 ? 0 : lastNewLine + 1;
    final currentLine = text.substring(currentLineStart, selection.start);

    if (currentLine.isEmpty || currentLine.startsWith(RegExp(r'\d+\.\s'))) {
      // Already a list item or empty line
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
      // Insert new list item
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

  // Bottom Navigation Items
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
    textController.dispose();
    summaryController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0: // Bold
        applyBoldFormat();
        break;
      case 1: // Italic
        applyItalicFormat();
        break;
      case 2: // Strikethrough
        applyStrikethroughFormat();
        break;
      case 3: // Numbered List
        addNumberedList();
        break;
      case 4: // Image
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

      // Insert image marker
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

      final response = await apiService.uploadOCRImage(imageFile, apiKey);
      Get.back(); // Tutup loading

      if (response == null || response['text'] == null) {
        Get.snackbar('Gagal', 'Gagal memproses OCR');
        return;
      }

      final extractedText = response['text'];
      final ocrTextController = TextEditingController(text: extractedText);

      Get.defaultDialog(
        title: 'Hasil OCR',
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: ocrTextController,
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
                  final ocrText = ocrTextController.text;

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

                  noteController
                      .textController
                      .selection = TextSelection.collapsed(
                    offset: selection.start + ocrText.length + 2,
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
    await _recorder.startRecorder(toFile: path);

    Get.snackbar(
      'Merekam',
      'Tekan untuk berhenti',
      duration: const Duration(seconds: 10),
      mainButton: TextButton(
        onPressed: () async {
          await _recorder.stopRecorder();
          await _recorder.closeRecorder();
          await _uploadAndShow(File(path));
        },
        child: const Text('Stop'),
      ),
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
          Get.snackbar('Berhasil', 'Audio berhasil ditranskripsi');
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
