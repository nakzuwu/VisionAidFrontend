import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vision_aid_app/app/data/model/note_model.dart';
import 'package:vision_aid_app/app/modules/note_detail/controllers/note_detail_controller.dart';
import 'package:vision_aid_app/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../../calendar/controllers/calendar_controller.dart';
import '../../../widgets/bottom_nav_bar.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    final CalendarController calendarController = Get.put(
      CalendarController(),
      permanent: true,
    );
    final NoteDetailController notesController = Get.put(
      NoteDetailController(),
      permanent: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notesController.allNotes.isEmpty) {
        notesController.loadAllNotes();
      }
    });

    final username = GetStorage().read('username') ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        onPressed: () {
          if (Get.isDialogOpen == true) Get.back();
          if (Get.isBottomSheetOpen == true) Get.back();

          Get.toNamed(Routes.NOTE_DETAIL);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo $username!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Apa yang kau lakukan hari ini?',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: searchController,
                              onChanged: (val) {
                                Future.microtask(() {
                                  searchQuery.value = val.toLowerCase();
                                });
                              },
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Cari catatan atau reminder...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              final query = searchQuery.value;
                              final reminders =
                                  calendarController.upcomingReminders;
                              final notes = notesController.allNotes;

                              final filteredReminders =
                                  query.isEmpty
                                      ? []
                                      : reminders.where((r) {
                                        final title =
                                            (r['title'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                        final desc =
                                            (r['description'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                        return title.contains(query) ||
                                            desc.contains(query);
                                      }).toList();

                              final filteredNotes =
                                  query.isEmpty
                                      ? []
                                      : notes.where((note) {
                                        final title = note.title.toLowerCase();
                                        final content =
                                            note.content.toLowerCase();
                                        return title.contains(query) ||
                                            content.contains(query);
                                      }).toList();

                              if (filteredReminders.isEmpty &&
                                  filteredNotes.isEmpty &&
                                  query.isNotEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Tidak ditemukan catatan atau pengingat yang cocok.',
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (filteredNotes.isNotEmpty) ...[
                                    const Text(
                                      'Hasil Catatan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...filteredNotes.map(
                                      (note) => ListTile(
                                        leading: const Icon(Icons.note),
                                        title: Text(note.title),
                                        subtitle: Text(
                                          note.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          Get.toNamed(
                                            Routes.NOTE_DETAIL,
                                            arguments: note.id,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (filteredReminders.isNotEmpty) ...[
                                    const Text(
                                      'Hasil Pengingat',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...filteredReminders.map(
                                      (reminder) => ListTile(
                                        leading: const Icon(
                                          Icons.notifications,
                                        ),
                                        title: Text(
                                          reminder['title'] ?? 'Reminder',
                                        ),
                                        subtitle: Text(
                                          reminder['description'] ?? '',
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 150,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/quotes.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Terakhir Dilihat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 20),
                                  tooltip: 'Muat ulang catatan terakhir',
                                  onPressed: () {
                                    final controller =
                                        Get.find<NoteDetailController>();
                                    controller.loadAllNotes();
                                  },
                                ),
                              ],
                            ),
                            Obx(() {
                              final controller =
                                  Get.find<NoteDetailController>();
                              final notes =
                                  controller.allNotes
                                      .where((n) => n.lastOpened != null)
                                      .toList()
                                    ..sort(
                                      (a, b) => b.lastOpened!.compareTo(
                                        a.lastOpened!,
                                      ),
                                    );
                              final last3 = notes.take(3).toList();
                              if (last3.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('Belum ada catatan yang dibuka.'),
                                );
                              }
                              return SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: last3.length,
                                  itemBuilder:
                                      (_, index) =>
                                          _buildNoteCard(last3[index]),
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                            const Text(
                              'Yang akan datang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() {
                              final query = searchQuery.value;
                              final allReminders =
                                  calendarController.upcomingReminders;
                              final filteredReminders =
                                  query.isEmpty
                                      ? allReminders
                                      : allReminders.where((r) {
                                        final title =
                                            (r['title'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                        final desc =
                                            (r['description'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                        return title.contains(query) ||
                                            desc.contains(query);
                                      }).toList();
                              if (filteredReminders.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('Tidak ada pengingat yang cocok'),
                                );
                              }
                              return Column(
                                children:
                                    filteredReminders.map((reminder) {
                                      final color =
                                          reminder['color'] as Color? ??
                                          Colors.blue;
                                      return Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.notifications,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    reminder['title'] ??
                                                        'Pengingat',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${reminder['date']}${reminder['time'] != null ? ' - ${reminder['time']}' : ''}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (reminder['description'] !=
                                                    null &&
                                                reminder['description']
                                                    .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  reminder['description'],
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              );
                            }),
                            const SizedBox(height: 24),
                            const Text(
                              'Statistik Folder',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(height: 200, child: _buildFolderChart()),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _openAnalytics,
                                icon: const Icon(Icons.bar_chart),
                                label: const Text('Lihat Statistik VisionAid'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow[700],
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Terakhir Dilihat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Obx(() {
          if (controller.recentNotes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Belum ada catatan yang dibuka.'),
            );
          }

          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.recentNotes.length,
              itemBuilder:
                  (_, index) => _buildNoteCard(controller.recentNotes[index]),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.NOTE_DETAIL, arguments: note.id);
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 10),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // 🔸 Batasi 1 baris
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  maxLines: 4, // 🔸 Batasi isi catatan maksimal 4 baris
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderChart() {
    final folderMap = GetStorage().read<Map>('folders') ?? {};
    final folderNames = folderMap.keys.toList();
    final folderCounts =
        folderMap.values.map((v) => (v as List).length).toList();

    if (folderNames.isEmpty) {
      return const Center(child: Text('Belum ada data folder'));
    }

    return BarChart(
      BarChartData(
        barGroups: List.generate(folderNames.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: folderCounts[i].toDouble(),
                color: Colors.blue,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < folderNames.length) {
                  final name = folderNames[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      name.length > 6 ? '${name.substring(0, 6)}..' : name,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Future<void> _openAnalytics() async {
    final Uri url = Uri.parse('https://visionaid.streamlit.app');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
