import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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

  /// เลือกรูปจาก gallery (หลายรูปได้) แล้วรวมเป็นรูปเดียวเมื่อเลือกมากกว่า 1
  static Future<SlipImageResult?> pickAndCompressImage() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 55,
        maxWidth: 700,
        maxHeight: 700,
      );

      if (pickedFiles.isEmpty) return null;

      final rawList = <Uint8List>[];
      for (final file in pickedFiles) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) rawList.add(bytes);
      }
      if (rawList.isEmpty) return null;

      if (rawList.length == 1) {
        final single = await _shrinkIfNeeded(rawList.first);
        return SlipImageResult(
          bytes: single,
          fileName: _fileNameOrDefault(pickedFiles.first, singleFileName),
          mimeType: 'image/jpeg',
        );
      }

      final merged = await mergeImages(rawList);
      if (merged == null) return null;

      return SlipImageResult(
        bytes: merged,
        fileName: mergedFileName,
        mimeType: 'image/jpeg',
        mergedCount: rawList.length,
      );
    } catch (e) {
      debugPrint('❌ pickAndCompressImage error: $e');
      return null;
    }
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
