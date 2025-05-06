import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MediaController extends GetxController {
  final picker = ImagePicker();

  Future<void> openCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Get.snackbar('Sukses', 'Foto berhasil diambil!');
    }
  }

  Future<void> openGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Get.snackbar('Sukses', 'Foto berhasil dipilih dari galeri!');
    }
  }
}
