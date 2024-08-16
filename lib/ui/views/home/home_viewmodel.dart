import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:roatate_file_tool/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
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

  void updateSelectedFiles(List<PlatformFile> files) {
    // Nếu selectedFiles chưa được khởi tạo, khởi tạo nó
    selectedFiles ??= [];

    // Lưu lại số lượng file hiện tại
    int previousLength = selectedFiles!.length;

    // Thêm tất cả các file mới vào danh sách hiện có
    selectedFiles!.addAll(files);

    // Cập nhật trạng thái cho các file đã có và file mới
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
    // const exePath = 'D:/locanh/process_files/dist/process_files.exe';

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
          print('File ${filePaths[i]} processed successfully.');
        } else {
          // Xử lý lỗi nếu cần
          print('Error processing file ${filePaths[i]}: ${result.stderr}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    // Notify listeners chỉ khi hoàn tất
    notifyListeners();
  }
}

class FileStatus {
  final int id;
  FileStatusType status;

  FileStatus({required this.id, required this.status});
}

enum FileStatusType { idle, loading, done }
