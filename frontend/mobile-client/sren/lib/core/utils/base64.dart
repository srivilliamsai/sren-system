import 'dart:convert';
import 'dart:typed_data';

Uint8List decodeBase64Image(String data) {
  final normalized = data.contains(',')
      ? data.split(',').last
      : data;
  return base64Decode(normalized);
}

String encodeToBase64(Uint8List bytes) => base64Encode(bytes);
