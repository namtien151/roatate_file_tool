import 'package:file_picker/file_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:roatate_file_tool/app/app.locator.dart';
import 'package:roatate_file_tool/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  List<PlatformFile>? selectedFiles = [];
  List<FileStatus> fileStatuses = [];
  double progressValue = 0.0;
  StartupViewModel() {
    // Initialize fileStatuses based on the number of selected files.
    fileStatuses = List.generate(selectedFiles?.length ?? 0, (index) => FileStatus(id: index, status: FileStatusType.idle));
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
          status: index < previousLength ? fileStatuses[index].status : FileStatusType.idle
      ),
    );

    // Thông báo cập nhật giao diện
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
      await Future.delayed(Duration(seconds: 2)); // Simulate delay
      fileStatuses[i].status = FileStatusType.done;
      progressValue = (i + 1) / totalFiles; // Update progress
      notifyListeners();
    }
  }

}
class FileStatus {
  final int id;
  FileStatusType status;

  FileStatus({required this.id, required this.status});
}

enum FileStatusType { idle, loading, done }