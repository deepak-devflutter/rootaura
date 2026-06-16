import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Picks images and uploads them to Firebase Storage under `products/`.
/// Works on web (uploads bytes) and mobile alike.
class ImageService {
  ImageService._();
  static final ImageService instance = ImageService._();

  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  /// Lets the admin pick multiple images. Returns the picked files (not yet
  /// uploaded) so the UI can preview them before saving.
  Future<List<XFile>> pick() => _picker.pickMultiImage(imageQuality: 80);

  /// Uploads one picked file and returns its public download URL.
  Future<String> upload(String productId, XFile file) async {
    final bytes = await file.readAsBytes();
    final name = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final ref = _storage.ref('products/$productId/$name');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: file.mimeType ?? 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  /// Uploads several files, preserving order.
  Future<List<String>> uploadAll(String productId, List<XFile> files) async {
    final urls = <String>[];
    for (final f in files) {
      urls.add(await upload(productId, f));
    }
    return urls;
  }
}
