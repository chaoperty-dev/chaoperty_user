import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:universal_html/html.dart' as html;

/// ผลลัพธ์รูปสลิปที่พร้อมอัปโหลด
///
/// เลือกได้หลายรูปแล้วรวมเป็นรูปเดียว เหมือนต้นฉบับ (`_pickSlipImage`)
/// เพื่อให้จำนวนไฟล์ที่รับเท่ากันทั้งสองเวอร์ชัน
class SlipImageResult {
  const SlipImageResult({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    this.mergedCount = 1,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;

  /// จำนวนรูปต้นทางที่ถูกรวม (1 = ไม่ได้รวม)
  final int mergedCount;

  bool get isMerged => mergedCount > 1;
}

/// พารามิเตอร์สำหรับ merge ใน isolate
class SlipMergeParams {
  const SlipMergeParams({required this.images});

  final List<Uint8List> images;
}

class PaymentSubV4SlipPicker {
  /// ความกว้างสูงสุดของรูปที่รวมแล้ว (ตามต้นฉบับ `_processSlipMergeImages`)
  static const int mergeMaxWidth = 450;

  /// คุณภาพ JPEG ของรูปที่รวมแล้ว (ตามต้นฉบับ)
  static const int mergeJpegQuality = 35;

  static const String mergedFileName = 'merged_slip.jpg';
  static const String singleFileName = 'slip_upload.jpg';

  /// เลือกรูปสลิปจาก gallery ได้ครั้งละ 1 รูป
  static Future<SlipImageResult?> pickAndCompressImage() async {
    try {
      if (kIsWeb) return _pickFromWeb();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 55,
        maxWidth: 700,
        maxHeight: 700,
      );
      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      if (bytes.isEmpty) return null;

      return SlipImageResult(
        bytes: await _shrinkIfNeeded(bytes),
        fileName: _fileNameOrDefault(pickedFile, singleFileName),
        mimeType: 'image/jpeg',
      );
    } catch (e) {
      debugPrint('❌ pickAndCompressImage error: $e');
      return null;
    }
  }

  /// Web ใช้ native file input ตาม legacy (`FileUploadInputElement`).
  /// ส่ง bytes ดิบกลับทันทีเพื่อไม่ให้การ decode/resize รูปบน UI thread ทำให้หน้าเว็บค้าง.
  static Future<SlipImageResult?> _pickFromWeb() async {
    final completer = Completer<SlipImageResult?>();
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false
      ..style.display = 'none';
    html.document.body?.append(input);

    void finish(SlipImageResult? result) {
      if (!completer.isCompleted) completer.complete(result);
      input.remove();
    }

    input.onAbort.listen((_) => finish(null));
    input.onError.listen((_) => finish(null));
    input.onChange.listen((_) async {
      final files = input.files;
      if (files == null || files.isEmpty) {
        finish(null);
        return;
      }

      try {
        final file = files.first;
        final reader = html.FileReader()..readAsArrayBuffer(file);
        await reader.onLoadEnd.first;
        final result = reader.result;
        final bytes = result is Uint8List
            ? result
            : result is ByteBuffer
                ? Uint8List.view(result)
                : null;
        if (bytes == null || bytes.isEmpty) {
          finish(null);
          return;
        }

        finish(SlipImageResult(
          bytes: bytes,
          fileName: file.name.isEmpty ? singleFileName : file.name,
          mimeType: mimeTypeFor(file.name),
        ));
      } catch (error) {
        debugPrint('❌ Web slip image read error: $error');
        finish(null);
      }
    });

    input.click();
    return completer.future;
  }
  /// รวมหลายรูปเป็นรูปเดียวในแนวตั้ง — ทำงานใน isolate เพื่อไม่บล็อก UI
  ///
  /// ล้มเหลวหรือ timeout จะคืนรูปแรกแทน เพื่อไม่ให้ผู้ใช้ต้องเลือกใหม่
  static Future<Uint8List?> mergeImages(List<Uint8List> images) async {
    if (images.isEmpty) return null;
    if (images.length == 1) return images.first;

    return compute(_processSlipMergeImages, SlipMergeParams(images: images))
        .timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        debugPrint('Slip image processing timed out');
        return images.first;
      },
    );
  }

  /// ย่อรูปเดี่ยวที่ใหญ่เกิน 800px ลงให้พอดี (ตามต้นฉบับ)
  static Future<Uint8List> _shrinkIfNeeded(Uint8List bytes) async {
    try {
      final original = img.decodeImage(bytes);
      if (original == null) return bytes;
      if (original.width <= 800 && original.height <= 800) return bytes;

      final resized = img.copyResize(
        original,
        width: original.width > original.height ? 800 : null,
        height: original.height >= original.width ? 800 : null,
      );
      return Uint8List.fromList(img.encodePng(resized));
    } catch (e) {
      debugPrint('⚠️ Resize image error: $e');
      return bytes;
    }
  }

  static String _fileNameOrDefault(XFile file, String fallback) {
    final name = file.name.trim();
    return name.isEmpty ? fallback : name;
  }

  /// สร้าง MIME type จากชื่อไฟล์
  static String mimeTypeFor(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    return ext == 'png' ? 'image/png' : 'image/jpeg';
  }
}

/// รวมรูปในแนวตั้ง (top-down) เหมือนต้นฉบับ `_processSlipMergeImages`
///
/// เป็น top-level function เพราะต้องส่งเข้า `compute` ได้
Future<Uint8List?> _processSlipMergeImages(SlipMergeParams params) async {
  try {
    const int maxWidth = PaymentSubV4SlipPicker.mergeMaxWidth;
    final decodedImages = <img.Image>[];
    var totalHeight = 0;

    for (final bytes in params.images) {
      var decoded = img.decodeImage(bytes);
      if (decoded == null) continue;

      if (decoded.width > maxWidth) {
        decoded = img.copyResize(
          decoded,
          width: maxWidth,
          interpolation: img.Interpolation.nearest,
        );
      }

      decodedImages.add(decoded);
      totalHeight += decoded.height;
    }

    if (decodedImages.isEmpty) return null;

    final mergedDisplay = img.Image(width: maxWidth, height: totalHeight);
    img.fill(mergedDisplay, color: img.ColorRgb8(255, 255, 255));

    var currentY = 0;
    for (final image in decodedImages) {
      img.compositeImage(mergedDisplay, image, dstX: 0, dstY: currentY);
      currentY += image.height;
    }

    return Uint8List.fromList(
      img.encodeJpg(
        mergedDisplay,
        quality: PaymentSubV4SlipPicker.mergeJpegQuality,
      ),
    );
  } catch (e) {
    debugPrint('Error merging images in isolate: $e');
    return null;
  }
}
