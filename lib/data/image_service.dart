import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Picks images and uploads them to Firebase Storage under `products/`.
/// Works on web (uploads bytes) and mobile alike.
class ImageService {
  ImageService._();
  static final ImageService instance = ImageService._();

  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  /// Longest edge kept for stored product images — plenty for the storefront
  /// and keeps every upload comfortably under the Storage size limit.
  static const int _maxDimension = 1600;
  static const int _jpegQuality = 82;

  /// Lets the admin pick multiple images. Returns the picked files (not yet
  /// uploaded) so the UI can preview them before saving.
  ///
  /// Note: `imageQuality`/`maxWidth` are IGNORED by image_picker on the web, so
  /// we downscale + re-encode ourselves in [upload] to guarantee small files
  /// on every platform.
  Future<List<XFile>> pick() => _picker.pickMultiImage();

  /// Uploads one picked file (downscaled + compressed) and returns its public
  /// download URL.
  Future<String> upload(String productId, XFile file) async {
    final raw = await file.readAsBytes();
    final (bytes, contentType) = _compress(raw, file.mimeType);
    final name = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final ref = _storage.ref('products/$productId/$name');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  /// Decodes, downscales (if larger than [_maxDimension]) and re-encodes as
  /// JPEG so uploads stay small and fast. If decoding fails for any reason the
  /// original bytes are returned unchanged.
  (Uint8List, String) _compress(Uint8List raw, String? mimeType) {
    try {
      final decoded = img.decodeImage(raw);
      if (decoded == null) return (raw, mimeType ?? 'image/jpeg');
      final needsResize =
          decoded.width > _maxDimension || decoded.height > _maxDimension;
      final image = needsResize
          ? img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? _maxDimension : null,
              height: decoded.height > decoded.width ? _maxDimension : null,
            )
          : decoded;
      final jpg = img.encodeJpg(image, quality: _jpegQuality);
      return (jpg, 'image/jpeg');
    } catch (_) {
      return (raw, mimeType ?? 'image/jpeg');
    }
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
