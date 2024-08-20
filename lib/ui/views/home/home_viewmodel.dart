import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:path/path.dart' as path;
import 'package:roatate_file_tool/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:math';
import '../../../app/app.locator.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  List<PlatformFile>? selectedFiles = [];
  List<FileStatus> fileStatuses = [];
  double progressValue = 0.0;
  bool _showFiles = false;
  String? _selectedDirectory;
  List<FileSystemEntity>? _files;
  bool get showFiles => _showFiles;

  String? get selectedDirectory => _selectedDirectory;
  List<FileSystemEntity>? get files => _files;
  StartupViewModel() {
    // Initialize fileStatuses based on the number of selected files.
    fileStatuses = List.generate(selectedFiles?.length ?? 0,
        (index) => FileStatus(id: index, status: FileStatusType.idle));
  }

  void removeFile(int index) {
    files?.removeAt(index);
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
      await Future.delayed(Duration(seconds: 1)); // Simulate delay
      await Future.delayed(const Duration(seconds: 5)); // Simulate delay
      fileStatuses[i].status = FileStatusType.done;
      progressValue = (i + 1) / totalFiles; // Update progress
      notifyListeners();
    }
  }

  Future<void> pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      _selectedDirectory = selectedDirectory;

      // Lấy tất cả các tệp PDF và hình ảnh trong thư mục và các thư mục con
      _files = _getFilesFromDirectory(Directory(selectedDirectory));
      fileStatuses = List.generate(_files!.length,
              (index) => FileStatus(id: index, status: FileStatusType.idle));
      _showFiles = false; // Ẩn danh sách file
      notifyListeners();
    }
  }

  List<FileSystemEntity> _getFilesFromDirectory(Directory directory) {
    List<FileSystemEntity> files = [];
    try {
      directory.listSync(recursive: true).forEach((file) {
        if (file is File && _isValidFileType(file)) {
          files.add(file);
        }
      });
    } catch (e) {
      print('Error reading directory: $e');
    }
    return files;
  }

  bool _isValidFileType(File file) {
    final extension = file.uri.pathSegments.last.split('.').last.toLowerCase();
    return extension == 'pdf' || _isImageExtension(extension);
  }

  bool _isImageExtension(String extension) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff'];
    return imageExtensions.contains(extension);
  }

  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${units[i]}';
  }
  void toggleFilesVisibility() {
    _showFiles = !_showFiles;
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
