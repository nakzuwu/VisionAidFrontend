import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/media_controller.dart';

class MediaView extends GetView<MediaController> {
  const MediaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Kamera / Galeri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () {}, // nanti bisa tambahkan toggle flash
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Icon(
                Icons.camera_alt,
                size: 100,
                color: Colors.yellow[700],
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: Colors.yellow[700], size: 36),
                  onPressed: controller.openGallery,
                ),
                GestureDetector(
                  onTap: controller.openCamera,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.switch_camera, color: Colors.yellow[700], size: 36),
                  onPressed: () {}, // nanti bisa tambahkan switch kamera
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
