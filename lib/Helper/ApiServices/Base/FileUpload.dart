import 'dart:convert';
import 'dart:typed_data';

// أو flutter_image_compress

// import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class FileUpload {
  FileUpload(
      {this.thumbnailData,
      // this.fileSelected,
      this.url,
      // this.originalFile,
      this.isVideo = false,
      this.fileId});
  Uint8List? thumbnailData;
  // XFile? originalFile;
  // AssetEntity? fileSelected;
  int? fileId;
  String? url;
  bool isVideo;

  String tobBase64() {
    if (thumbnailData == null) {
      return "";
    }
    String base64String = base64Encode(thumbnailData!);
    // String header = "data:image/png;base64,";
    String header = "data:image/jpeg;base64,";
    return header + base64String;
  }
}

class FileUpload2 {
  FileUpload2({
    this.thumbnailData,
    this.fileName,
    this.fileId,
    this.url,
    this.isVideo = false,
  });

  Uint8List? thumbnailData;
  String? fileName;
  int? fileId;
  String? url;
  bool isVideo;

  /// فقط base64 بدون هيدر
  String toBase64Raw() {
    if (thumbnailData == null) return "";
    return base64Encode(thumbnailData!);
  }

  /// مع الهيدر (لو احتجته)
  String toBase64WithHeader() {
    if (thumbnailData == null) return "";
    return "data:image/jpeg;base64,${base64Encode(thumbnailData!)}";
  }
}
