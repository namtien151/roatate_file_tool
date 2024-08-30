import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultTurnDialogModel extends BaseViewModel {
  BuildContext context;
  ResultTurnDialogModel(this.context);
  String? filePath;
  String? fileNameNPro;

  // Thay đổi để nhận đường dẫn tệp từ bên ngoài
  void setFilePath(String path) {
    filePath = path;
    notifyListeners();
  }
  void setFilePath1(String path) {
    fileNameNPro = path;
    notifyListeners();
  }

  // Phương thức mở tệp
  Future<void> openFile() async {
    print('Opening file: $filePath');
    if (filePath != null) {
      final fileUri = Uri.file(filePath!);
      final fileDirectory = fileUri.resolve('.').toFilePath(); // Lấy thư mục chứa tệp

      if (Platform.isWindows) {
        try {
          Process.run('explorer', ['/select,${fileUri.toFilePath()}']);
        } catch (e) {
          print('Could not open file: $filePath');
          print(e);
        }
      } else if (Platform.isMacOS) {
        try {
          Process.run('open', ['-R', fileUri.toFilePath()]);
        } catch (e) {
          print('Could not open file: $filePath');
          print(e);
        }
      } else {
        // Nếu không phải Windows hoặc macOS, bạn có thể thêm hỗ trợ cho các nền tảng khác ở đây.
        print('Platform not supported for opening file');
      }
    }
  }
}
