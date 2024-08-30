import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:path/path.dart' as path;
import 'package:stacked_services/stacked_services.dart';
import 'dart:math';
import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../widget/notify/show_notify.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  BuildContext context;
  HomeViewModel(this.context);

  List<FileStatus> fileStatuses = [];
  double progressValue = 0.0;
  bool _showFiles = false;
  String? _selectedDirectory;
  List<FileSystemEntity>? _files;
  bool get showFiles => _showFiles;
  String processingStatus = '';
  bool showDeleteButton = false;
  bool _isCancelled = false;
  String? currentFilePath;
  String data = '';

  String? get selectedDirectory => _selectedDirectory;
  List<FileSystemEntity>? get files => _files;

  final _dialogService = locator<DialogService>();

  void removeFile(int index) {
    files?.removeAt(index);
    notifyListeners();
  }

  Future<void> rotateFiles() async {
    if (files == null || files!.isEmpty) return;

    int totalFiles = files!.length;
    progressValue = 0.0; // Reset progress

    for (int i = 0; i < totalFiles; i++) {
      fileStatuses[i].status = FileStatusType.loading;
    }
    notifyListeners();

    for (int i = 0; i < totalFiles; i++) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay
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
    final fileSize = bytes / pow(1024, i);
    final formattedSize = fileSize.toStringAsFixed(2);

    // Trả về kích thước và đơn vị tính
    return '$formattedSize ${units[i]}';
  }

  bool isFileLarge(int bytes) {
    const tenMB = 10 * 1024 * 1024; // 10 MB in bytes
    return bytes > tenMB;
  }

  void toggleFilesVisibility() {
    _showFiles = !_showFiles;
    notifyListeners();
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
    completedFiles = 0;
    print(_outputDirectory);
    if (_outputDirectory.isEmpty) {
      showNotify(context, titleText: "vui lòng chọn nơi lưu", success: false);
      return;
    }

    if (_files == null || _files!.isEmpty) return;

    List<String> filePaths = _files!.map((file) => file.path).toList();

    int totalFiles = _files!.length;
    progressValue = 0.0; // Reset progress

    // Cập nhật trạng thái cho tất cả các tệp là loading
    for (int i = 0; i < totalFiles; i++) {
      fileStatuses[i].status = FileStatusType.loading;
    }
    notifyListeners();

    List<Future<void>> processingTasks = [];
    const int batchSize = 3; // Số tệp xử lý cùng lúc

    for (int i = 0; i < totalFiles; i += batchSize) {
      List<Future<void>> batchTasks = [];

      for (int j = i; j < i + batchSize && j < totalFiles; j++) {
        // Kiểm tra nếu bị hủy bỏ
        if (_isCancelled) {
          break;
        }

        final arguments = [
          _outputDirectory,
          filePaths[j], // Chỉ truyền một tệp tại một thời điểm
        ];

        batchTasks.add(_processFile(exePath, arguments, j, totalFiles));
      }

      // Chạy các nhiệm vụ trong batch cùng lúc
      await Future.wait(batchTasks);
    }

    // Xử lý sau khi hoàn thành hoặc bị hủy bỏ
    if (!_isCancelled) {
      showNotify(context,
          titleText: "Xử lý xoay file thành công", success: true);
    } else {
      // Xử lý khi bị hủy bỏ, nếu cần
      showNotify(context, titleText: "Xử lý bị hủy", success: false);
    }

    // Đặt lại cờ hủy bỏ
    _isCancelled = false;
    notifyListeners();
  }

  int completedFiles = 0; // Biến đếm số tệp đã hoàn thành

  Future<void> _processFile(
      String exePath, List<String> arguments, int index, int totalFiles) async {
    try {
      final result = await Process.run(exePath, arguments);
      final fileName = arguments[1].split('/').last.split('\\').last;
      final outputFilePath = '$_outputDirectory\\$fileName';

      if (result.stdout.contains("Done")) {
        fileStatuses[index].status = FileStatusType.done;

        // Cập nhật số tệp đã hoàn thành
        completedFiles++;
        progressValue = completedFiles /
            totalFiles; // Cập nhật tiến trình dựa trên số tệp đã hoàn thành

        notifyListeners();
        processingStatus = '$completedFiles File processed successfully.';
        notifyListeners();
        showDeleteButton = true;
        notifyListeners();
        currentFilePath = outputFilePath;
        print(outputFilePath);
      } else {
        // Xử lý lỗi nếu cần
        // log('Error processing file ${arguments[1]}: ${result.stderr}');
      }
    } catch (e) {
      // log('Error: $e');
    }
  }

  void clearAll() {
    // Xóa danh sách các file đã chọn

    // Đặt lại danh sách file và trạng thái
    _isCancelled = true;
    _files?.clear();
    fileStatuses.clear();
    _selectedDirectory = null;

    // Đặt lại thư mục đầu ra
    _outputDirectory = '';

    processingStatus = '';

    progressValue = 0.0;
    _selectedDirectory = '';

    // Đặt lại trạng thái hiển thị
    showDeleteButton = false;

    // Cập nhật trạng thái giao diện
    notifyListeners();
  }

  Future<void> openDialogResult(int index) async {
    try {
      // Lấy đường dẫn tệp từ chỉ số index
      final fileName = files?[index].path.split('/').last.split('\\').last;
      final outputFilePath = '$_outputDirectory\\$fileName';
      final fileNameNPro = files?[index].path;

      // Gọi phương thức showCustomDialog để hiển thị dialog
      final DialogResponse? response = await _dialogService.showCustomDialog(
        variant: DialogType.resultTurn, // Thay đổi loại dialog nếu cần
        title: 'Ket Qua', // Tiêu đề của dialog
        data: {
          'filePath': outputFilePath,
          'fileNameNPro': fileNameNPro
        }, // Truyền đường dẫn tệp vào dialog
      );

      if (response == true) {
        print("thanh cong");
      } else {
        print("gg");
      }

      // Kiểm tra phản hồi từ dialog
    } catch (e) {
      print('Error handling result dialog: $e');
      // Xử lý lỗi nếu cần
    }
  }
}

class FileStatus {
  final int id;
  FileStatusType status;

  FileStatus({required this.id, required this.status});
}

enum FileStatusType { idle, loading, done }
