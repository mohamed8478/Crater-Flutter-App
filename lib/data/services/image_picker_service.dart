import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Captures a photo using the device camera.
  Future<XFile?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );
      return photo;
    } catch (e) {
      // In a real app, I'd log this or handle permission-specific errors
      return null;
    }
  }

  /// Picks an image from the user's gallery.
  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      return image;
    } catch (e) {
      return null;
    }
  }
}
