import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:roatate_file_tool/ui/views/widget/notify/show_notify.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  BuildContext context;
  HomeViewModel(this.context);
  List<PlatformFile>? selectedFiles = [];
  List<FileStatus> fileStatuses = [];
  double progressValue = 0.0;
  StartupViewModel() {
    // Initialize fileStatuses based on the number of selected files.
    fileStatuses = List.generate(selectedFiles?.length ?? 0,
        (index) => FileStatus(id: index, status: FileStatusType.idle));
  }

  void removeFile(int index) {
    selectedFiles?.removeAt(index);
    notifyListeners();
  }

  void updateSelectedFiles(List<PlatformFile> files) async {
    selectedFiles ??= [];
    int previousLength = selectedFiles!.length;
    List<PlatformFile> newFiles = [];
    for (var file in files) {
      bool exists =
          selectedFiles!.any((selectedFile) => selectedFile.path == file.path);
      bool exists1 =
          selectedFiles!.any((selectedFile) => selectedFile.name == file.name);
      if (!exists) {
        if (!exists1) {
          newFiles.add(file);
        } else {
          showNotify(
            context,
            titleText: "File ${file.name} đã tồn tại.",
            error: true,
          );
          await Future.delayed(const Duration(milliseconds: 600));
        }
      } else {
        showNotify(
          context,
          titleText: "File ${file.name} đã tồn tại.",
          error: true,
        );
        await Future.delayed(const Duration(milliseconds: 600));
        log('File ${file.name} đã tồn tại.');
      }
    }

    // Thêm các tệp mới không trùng lặp vào danh sách hiện có
    selectedFiles!.addAll(newFiles);

    // Cập nhật trạng thái cho các tệp đã có và tệp mới
    fileStatuses = List.generate(
      selectedFiles!.length,
      (index) => FileStatus(
          id: index,
          status: index < previousLength
              ? fileStatuses[index].status
              : FileStatusType.idle),
    );

    notifyListeners();
  }

  Future<void> rotateFiles() async {
    if (selectedFiles == null || selectedFiles!.isEmpty) return;

    int totalFiles = selectedFiles!.length;
    progressValue = 0.0; // Reset progress

    for (int i = 0; i < totalFiles; i++) {
      fileStatuses[i].status = FileStatusType.loading;
    }
    notifyListeners();

    for (int i = 0; i < totalFiles; i++) {
      await Future.delayed(const Duration(seconds: 5)); // Simulate delay
      fileStatuses[i].status = FileStatusType.done;
      progressValue = (i + 1) / totalFiles; // Update progress
      notifyListeners();
    }
  }

  String _outputDirectory = "";
  String get outputDirectory => _outputDirectory;

  Future<void> pickOutputDirectory() async {
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      _outputDirectory = result;
      notifyListeners();
    }
  }

  Future<void> runExecutable() async {
    const exePath = 'lib/services/process_files/dist/process_files.exe';

    if (selectedFiles == null || selectedFiles!.isEmpty) return;

    List<String> filePaths = selectedFiles!.map((file) => file.path!).toList();

    int totalFiles = selectedFiles!.length;
    progressValue = 0.0; // Reset progress

    // Cập nhật trạng thái cho tất cả các tệp là loading
    for (int i = 0; i < totalFiles; i++) {
      fileStatuses[i].status = FileStatusType.loading;
    }
    notifyListeners();

    for (int i = 0; i < totalFiles; i++) {
      final arguments = [
        _outputDirectory,
        filePaths[i], // Chỉ truyền một tệp tại một thời điểm
      ];

      try {
        final result = await Process.run(exePath, arguments);

        if (result.stdout.contains("Done")) {
          fileStatuses[i].status = FileStatusType.done;
          progressValue = (i + 1) / totalFiles; // Cập nhật tiến trình
          notifyListeners();
          log('File ${filePaths[i]} processed successfully.');
        } else {
          // Xử lý lỗi nếu cần
          log('Error processing file ${filePaths[i]}: ${result.stderr}');
        }
      } catch (e) {
        log('Error: $e');
      }
    }
    showNotify(context, titleText: "Xử lý xoay file thành công", success: true);
    notifyListeners();
  }
}

class FileStatus {
  final int id;
  FileStatusType status;

  FileStatus({required this.id, required this.status});
}

enum FileStatusType { idle, loading, done }
