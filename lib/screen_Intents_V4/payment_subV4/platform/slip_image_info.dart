import 'dart:typed_data';

class SlipImageInfo {
  const SlipImageInfo(this.extension, this.width, this.height);

  final String extension;
  final int width;
  final int height;

  /// Checks the file container and reads dimensions without decoding pixels.
  static SlipImageInfo? inspect(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    if (bytes.length >= 2 && data.getUint16(0) == 0xffd8) {
      return _inspectJpeg(bytes, data);
    }
    if (bytes.length >= 8 &&
        data.getUint32(0) == 0x89504e47 &&
        data.getUint32(4) == 0x0d0a1a0a) {
      return _inspectPng(bytes, data);
    }
    return null;
  }

  static SlipImageInfo? _inspectJpeg(Uint8List bytes, ByteData data) {
    SlipImageInfo? info;
    var offset = 2;
    var inScan = false;
    var hasScanData = false;
    var finishedScan = false;
    while (offset < bytes.length) {
      if (bytes[offset++] != 0xff) {
        if (!inScan) return null;
        hasScanData = true;
        continue;
      }
      while (offset < bytes.length && bytes[offset] == 0xff) {
        offset++;
      }
      if (offset == bytes.length) return null;
      final marker = bytes[offset++];
      if (inScan && marker == 0) {
        hasScanData = true;
        continue;
      }
      if (inScan && marker >= 0xd0 && marker <= 0xd7) continue;
      if (inScan) {
        if (!hasScanData) return null;
        inScan = false;
        finishedScan = true;
      }
      if (marker == 0xd9) return finishedScan ? info : null;
      if (marker == 0 || marker == 0xd8 || offset + 2 > bytes.length) {
        return null;
      }
      final size = data.getUint16(offset);
      if (size < 2 || size > bytes.length - offset) return null;
      if (marker == 0xc0 || marker == 0xc1 || marker == 0xc2) {
        if (info != null || size < 11) return null;
        final components = bytes[offset + 7];
        final height = data.getUint16(offset + 3);
        final width = data.getUint16(offset + 5);
        if (components == 0 ||
            size != 8 + 3 * components ||
            width == 0 ||
            height == 0) {
          return null;
        }
        info = SlipImageInfo('jpg', width, height);
      } else if (marker == 0xda) {
        if (info == null || size < 8) return null;
        final components = bytes[offset + 2];
        if (components == 0 || size != 6 + 2 * components) return null;
        inScan = true;
        hasScanData = false;
      }
      offset += size;
    }
    return null;
  }

  static SlipImageInfo? _inspectPng(Uint8List bytes, ByteData data) {
    const header = 0x49484452; // IHDR
    const imageData = 0x49444154; // IDAT
    const palette = 0x504c5445; // PLTE
    const end = 0x49454e44; // IEND
    SlipImageInfo? info;
    var hasImageData = false;
    var hasPalette = false;
    var requiresPalette = false;
    var imageDataEnded = false;
    var offset = 8;
    while (offset + 12 <= bytes.length) {
      final size = data.getUint32(offset);
      if (size > bytes.length - offset - 12) return null;
      final type = data.getUint32(offset + 4);
      final payload = offset + 8;
      final checksumOffset = payload + size;
      if (_pngChecksum(bytes, offset + 4, checksumOffset) !=
          data.getUint32(checksumOffset)) {
        return null;
      }
      if (info == null) {
        if (type != header || size != 13) return null;
        final width = data.getUint32(payload);
        final height = data.getUint32(payload + 4);
        if (width == 0 ||
            height == 0 ||
            width > 0x7fffffff ||
            height > 0x7fffffff ||
            bytes[payload + 10] != 0 ||
            bytes[payload + 11] != 0 ||
            bytes[payload + 12] > 1) {
          return null;
        }
        final depth = bytes[payload + 8];
        final colorType = bytes[payload + 9];
        final validDepth = switch (colorType) {
          0 => const [1, 2, 4, 8, 16].contains(depth),
          3 => const [1, 2, 4, 8].contains(depth),
          2 || 4 || 6 => depth == 8 || depth == 16,
          _ => false,
        };
        if (!validDepth) return null;
        requiresPalette = colorType == 3;
        info = SlipImageInfo('png', width, height);
      } else if (type == header) {
        return null;
      } else if (type == imageData) {
        if (imageDataEnded || (requiresPalette && !hasPalette)) return null;
        hasImageData = hasImageData || size > 0;
      } else if (type == end) {
        return hasImageData && size == 0 ? info : null;
      } else {
        if (type == palette) {
          if (hasPalette ||
              hasImageData ||
              size == 0 ||
              size > 768 ||
              size % 3 != 0) {
            return null;
          }
          hasPalette = true;
        }
        imageDataEnded = imageDataEnded || hasImageData;
      }
      offset = checksumOffset + 4;
    }
    return null;
  }

  static final _crcTable = List<int>.generate(256, (value) {
    var crc = value;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc >>> 1) ^ ((crc & 1) == 0 ? 0 : 0xedb88320);
    }
    return crc;
  });

  static int _pngChecksum(Uint8List bytes, int start, int end) {
    var crc = 0xffffffff;
    for (var i = start; i < end; i++) {
      crc = (crc >>> 8) ^ _crcTable[(crc ^ bytes[i]) & 0xff];
    }
    return (crc ^ 0xffffffff) >>> 0;
  }
}
