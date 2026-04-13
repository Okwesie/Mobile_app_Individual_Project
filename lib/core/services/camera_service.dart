import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class CameraService {
  CameraService._();
  static final CameraService instance = CameraService._();

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Opens camera, saves image to app documents dir, returns the saved path.
  /// Returns null if user cancels.
  /// Throws a [String] on error.
  Future<String?> capturePhoto() async {
    final XFile? xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (xFile == null) return null;

    return _saveToDocuments(xFile.path);
  }

  /// Opens gallery picker. Returns null if user cancels.
  Future<String?> pickFromGallery() async {
    final XFile? xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (xFile == null) return null;

    return _saveToDocuments(xFile.path);
  }

  Future<String> _saveToDocuments(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'log_photos'));
    if (!photosDir.existsSync()) photosDir.createSync(recursive: true);

    final ext = p.extension(sourcePath).isNotEmpty
        ? p.extension(sourcePath)
        : '.jpg';
    final fileName = '${_uuid.v4()}$ext';
    final dest = p.join(photosDir.path, fileName);

    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}
