import 'dart:convert';
import 'dart:math';

import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/j_var.dart';
import 'package:flutter/cupertino.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../modals/common/jfile.dart';

// import '';
class CreatePostProvider extends ChangeNotifier {
  List<JFile> _fileList = [];

  List<JFile> get fileList => _fileList;

  set fileList(List<JFile> value) {
    _fileList = value;
    notifyListeners();
  }

  generateRandomId() {
    return DateTime.now().microsecondsSinceEpoch.toString() +
        Random().toString();
  }
  removeFileItem(uid){
    int index = _fileList.indexWhere((element) => element.uid == uid);
    _fileList.removeAt(index);
    notifyListeners();
  }

  uploadPostFiles(postId) async {
    for (int i = 0; i < _fileList.length; i++) {
      _fileList[i].isUploading = true;
    }
    fileList = _fileList;
    updateCheck(postId);
    for (int i = 0; i < fileList.length; i++) {
      String dir = JVar.imagePaths.postDocument;
      if (_fileList[i].fileType == JFileType.VIDEO) {
        dir = JVar.imagePaths.videoDocument;
      }
      if (_fileList[i].file != null) {
        uploadFiles(dir, fileList[i].file).then((url) {
          _fileList[i].isUploading = false;
          notifyListeners();
          if (url.isNotEmpty) {
            _fileList[i].fileUrl = url;
          } else {
            _fileList[i].isFailed = true;
          }
          updateCheck(postId);
        });
      }
    }
  }
  updateCheck(postId){
    var count = _fileList.where((element) => element.isUploading).length;
    if(count < 1){
      updatePostFiles(postId);
    }
  }
  updatePostFiles(postId) async {
    var response =
        await JApiService().postRequest(JApi.UPDATE_POST_FILES + "/${postId}", {
      "video_files": json.encode(fileList
              .where((element) => element.fileType == JFileType.VIDEO)
              .map((e) => e.fileUrl).toList() ??
          []),
      "image_files": json.encode(fileList
              .where((element) => element.fileType == JFileType.IMAGE)
              .map((e) => e.fileUrl).toList() ??
          []),
      "doc_files": json.encode(fileList
              .where((element) => element.fileType == JFileType.DOCUMENT)
              .map((e) => e.fileUrl).toList() ??
          []),
      "post_id": postId.toString(),
    });
    _fileList.clear();
    notifyListeners();
    if (response != null) {
      showToast("Successfully posted");
      return;
    }
    showToast("Error occur while uploading files.");
  }

  Future<String> uploadFiles(type, file) async {
    JApiService apiService = JApiService();
    String imgUrl = '';
    var response = await apiService.postMultiPartRequest(
      JApi.UPLOAD_FILE + "/" + type,
      {"file": file},
    );
    if (response != null) {
      print('responseURL: ${response!["url"]}');
      imgUrl = response["url"];
      return imgUrl;
    } else
      return '';
  }
}
