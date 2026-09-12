import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class SlipImageResult {
  const SlipImageResult({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

class PaymentSubV4SlipPicker {
  static Future<SlipImageResult?> pickAndCompressImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 55,
        maxWidth: 700,
        maxHeight: 700,
      );

      if (pickedFile == null) return null;

      var bytes = await pickedFile.readAsBytes();

      // ปรับขนาดภาพถ้าเกิน 800px เพื่อไม่ให้สลิปไฟล์ใหญ่เกินไป
      try {
        final original = img.decodeImage(bytes);
        if (original != null && (original.width > 800 || original.height > 800)) {
          final resized = img.copyResize(
            original,
            width: original.width > original.height ? 800 : null,
            height: original.height >= original.width ? 800 : null,
          );
          bytes = Uint8List.fromList(img.encodePng(resized));
        }
      } catch (e) {
        debugPrint('⚠️ Resize image error: $e');
      }

      final fileName = pickedFile.name.isNotEmpty
          ? pickedFile.name
          : 'slip_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ext = fileName.toLowerCase().split('.').last;
      final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';

      return SlipImageResult(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (e) {
      debugPrint('❌ pickAndCompressImage error: $e');
      return null;
    }
  }
}
