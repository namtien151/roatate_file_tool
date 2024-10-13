import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:math';
import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../widget/notify/show_notify.dart';

class HomeViewModel extends BaseViewModel {
  // final _navigationService = locator<NavigationService>();
  Queue<FileSystemEntity> fileQueue = Queue();
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
  static bool _isCancelled = false;
  String? currentFilePath;
  String data = '';

  final Semaphore semaphore = Semaphore(3);

  String? get selectedDirectory => _selectedDirectory;
  List<FileSystemEntity>? get files => _files;

  final _dialogService = locator<DialogService>();

  int? _selectedFileCount; // Biến để lưu số lượng tệp đã chọn

  int? get selectedFileCount => _selectedFileCount;

  void setSelectedFileCount(int? value) {
    _selectedFileCount = value;
    notifyListeners(); // Thông báo cho UI rằng có sự thay đổi
  }

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

    if (_outputDirectory.isEmpty) {
      showNotify(context, titleText: "Vui lòng chọn nơi lưu", success: false);
      return;
    }

    if (_files == null || _files!.isEmpty) return;

    List<String> filePaths = _files!.map((file) => file.path).toList();
    int totalFiles = _files!.length;
    progressValue = 0.0;

    for (int i = 0; i < totalFiles; i++) {
      fileStatuses[i].status = FileStatusType.loading;
    }
    notifyListeners();

    // Thêm tất cả các file vào queue
    for (int i = 0; i < totalFiles; i++) {
      fileQueue.add(_files![i]); // Thêm các file vào queue
    }

    // Chạy 3 tasks đầu tiên
    for (int i = 0; i < 3; i++) {
      _startNextTask(exePath, totalFiles);
    }
  }

  Future<void> _startNextTask(String exePath, int totalFiles) async {
    if (fileQueue.isEmpty) return; // Nếu không còn task nào trong queue thì return

    final file = fileQueue.removeFirst(); // Lấy file tiếp theo từ queue
    final index = _files!.indexOf(file); // Lấy index của file
    final arguments = [_outputDirectory, file.path];

    // Chạy task xử lý file
    await _processFileWithIsolate(exePath, arguments, index, totalFiles);
  }

  Future<void> _processFileWithIsolate(
      String exePath, List<String> arguments, int index, int totalFiles) async {
    await semaphore.acquire(); // Acquire một phép semaphore trước khi chạy task

    final receivePort = ReceivePort();

    final isolate = await Isolate.spawn(
        _isolateEntryPoint, [exePath, arguments, receivePort.sendPort, index, totalFiles]);

    receivePort.listen((message) {
      if (message is Map) {
        if (message.containsKey('progress')) {
          fileStatuses[index].progress = message['progress'];
          if (index % 10 == 0) notifyListeners(); // Giảm tần suất cập nhật UI
        } else if (message.containsKey('status') && message['status'] == 'done') {
          fileStatuses[index].status = FileStatusType.done;
          completedFiles++;
          progressValue = completedFiles / totalFiles;
          showDeleteButton = true;
          notifyListeners();

          // Khi hoàn thành task, giải phóng semaphore và chạy task tiếp theo
          semaphore.release();
          _startNextTask(exePath, totalFiles);  // Bắt đầu task tiếp theo sau khi giải phóng
        }
      }
    }).onDone(() {
      // Đảm bảo giải phóng semaphore khi xong
      semaphore.release();
    });
  }

  static void _isolateEntryPoint(List<dynamic> args) async {
    final exePath = args[0] as String;
    final arguments = args[1] as List<String>;
    final sendPort = args[2] as SendPort;
    final process = await Process.start(exePath, arguments);

    process.stdout.transform(utf8.decoder).listen((output) {
      if (_isCancelled) {
        process.kill();
        return;
      }
      if (output.contains('progress')) {
        final progressData = jsonDecode(output);
        sendPort.send({'progress': progressData['progress']});
      } else if (output.contains("Done")) {
        sendPort.send({'status': 'done'});
      }
    });

    await process.exitCode;
  }

  static List<Process> runningProcesses = [];
  int completedFiles = 0;

  void clearAll() {
    // Đặt cờ hủy bỏ để dừng các nhiệm vụ đang chạy
    _isCancelled = true;

    // Xóa danh sách các file đã chọn
    _files?.clear();
    fileStatuses.clear();
    _selectedDirectory = null;

    for (var process in runningProcesses) {
      // Sử dụng taskkill để đảm bảo hủy toàn bộ tiến trình và các tiến trình con
      Process.run('taskkill', ['/F', '/T', '/PID', process.pid.toString()]);
    }

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

  void resetProgress(int index) {
    if (index >= 0 && index < fileStatuses.length) {
      fileStatuses[index].progress = 0;
      notifyListeners(); // Thông báo cho UI về sự thay đổi dữ liệu
    }
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
  double progress; // Thêm thuộc tính tiến trình

  FileStatus({required this.id, required this.status, this.progress = 0.0});
}

enum FileStatusType { idle, loading, done }

class Semaphore {
  final int maxConcurrent;
  int _currentCount = 0;
  final List<Completer<void>> _waiting = []; // Danh sách các Completer đang chờ

  Semaphore(this.maxConcurrent);

  Future<void> acquire() async {
    if (_currentCount >= maxConcurrent) {
      final completer = Completer<void>();
      _waiting.add(completer);
      await completer.future;
    }
    _currentCount++;
  }

  void release() {
    _currentCount--;
    if (_waiting.isNotEmpty) {
      final completer = _waiting.removeAt(0);
      completer.complete();
    }
  }
}
