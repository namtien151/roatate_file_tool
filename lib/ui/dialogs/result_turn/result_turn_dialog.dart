import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roatate_file_tool/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'result_turn_dialog_model.dart';

class ResultTurnDialog extends StackedView<ResultTurnDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ResultTurnDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      ResultTurnDialogModel viewModel,
      Widget? child,
      ) {
    print(viewModel.filePath);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row chứa Text và IconButton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text widget
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Kết Quả',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // IconButton widget
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                    onPressed: () {
                      completer(DialogResponse(confirmed: false));
                    },
                  ),
                ),
              ],
            ),
            // Hiển thị PDF nếu có đường dẫn tệp

            Row(
              children: [
                // Hiển thị file đầu tiên
                SizedBox(
                  width: halfScreenWidth(context) / 1.2,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: viewModel.fileNameNPro!.toLowerCase().endsWith('.pdf')
                      ? SfPdfViewer.file(File(viewModel.fileNameNPro!))
                      : Image.file(File(viewModel.fileNameNPro!)),
                ),
                // Kiểm tra nếu filePath không rỗng và tồn tại
                if (viewModel.filePath!.isNotEmpty && File(viewModel.filePath!).existsSync())
                  Row(
                    children: [
                      // Thêm mũi tên phân cách
                      Icon(Icons.arrow_forward, size: 100),
                      // Hiển thị file thứ hai
                      SizedBox(
                        width: halfScreenWidth(context) / 1.2,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: viewModel.filePath!.toLowerCase().endsWith('.pdf')
                            ? SfPdfViewer.file(File(viewModel.filePath!))
                            : Image.file(File(viewModel.filePath!)),
                      ),
                    ],
                  ),
              ],
            ),


            // Nếu không có filePath, hiển thị thông báo hoặc placeholder

          ],
        ),
      ),
    );
  }

  @override
  ResultTurnDialogModel viewModelBuilder(BuildContext context) => ResultTurnDialogModel(context);
  @override
  void onViewModelReady(ResultTurnDialogModel viewModel) {
    viewModel.setFilePath(request.data['filePath'] as String);
    viewModel.setFilePath1(request.data['fileNameNPro'] as String);

    super.onViewModelReady(viewModel);
  }
}
