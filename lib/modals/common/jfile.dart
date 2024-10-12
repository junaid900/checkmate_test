import 'dart:io';

enum JFileType { IMAGE, VIDEO, DOCUMENT }

class JFile {
  String? uid;
  String? fileUrl;
  File? file;
  JFileType? fileType;
  bool isUploading = false;
  bool isFailed = false;

  JFile(
      {this.file,
      this.isUploading = false,
      this.isFailed = false,
      this.fileUrl,
      required this.uid,
      this.fileType = JFileType.IMAGE});
}
