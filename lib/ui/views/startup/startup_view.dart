import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:stacked/stacked.dart';
import 'package:dotted_border/dotted_border.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.5,
            height: 780,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4), // Vị trí bóng
                  blurRadius: 10, // Độ mờ của bóng
                  spreadRadius: 1, // Độ lan rộng của bóng
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0), // Khoảng cách với đường viền
              child: Column(
                children: [
                  SizedBox(height: 20), // Khoảng cách giữa các phần tử
                  DottedBorder(
                    color: Colors.black26,
                    strokeWidth: 1.5,
                    dashPattern: [10, 7],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(12),
                    child: Container(
                      height: 200,
                      width: 900,
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              height: 100,
                              width: 100,
                              child: Image.asset(
                                'assets/image/iconUpload.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const Text(
                            'Drag and drop files here',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black26),
                          ),
                          const Text(
                            '-OR-',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black26),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black26,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.black26,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.black26),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(allowMultiple: true);

                              if (result != null) {
                                List<PlatformFile> files = result.files;
                                viewModel.updateSelectedFiles(files);
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: Text(
                              'Choose Files',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    child: Container(
                      width: 900,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: viewModel.selectedFiles != null &&
                              viewModel.selectedFiles!.isNotEmpty
                          ? ListView.builder(
                              itemCount: viewModel.selectedFiles!.length,
                              itemBuilder: (context, index) {
                                PlatformFile fileItem =
                                    viewModel.selectedFiles![index];
                                FileStatusType status =
                                    viewModel.fileStatuses[index].status;
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 3), // Vị trí bóng
                                        blurRadius: 10, // Độ mờ của bóng
                                        spreadRadius:
                                            0.5, // Độ lan rộng của bóng
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      fileItem.name,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      fileItem.size < 1024 * 1024
                                          ? '${(fileItem.size / 1024).toStringAsFixed(2)} KB' // Nếu kích thước nhỏ hơn 1 MB, hiển thị theo KB
                                          : '${(fileItem.size / 1024 / 1024).toStringAsFixed(2)} MB', // Nếu kích thước lớn hơn 1 MB, hiển thị theo MB
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w100,
                                      ),
                                    ),


                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Icon trạng thái dựa trên điều kiện
                                        status == FileStatusType.idle
                                            ? Image.asset(
                                                'assets/image/close.png')
                                            : status == FileStatusType.loading
                                                ? CircularProgressIndicator() // Biểu tượng loading
                                                : Icon(Icons.check_circle,
                                                    color: Colors
                                                        .green), // Trạng thái done

                                        // Icon delete luôn hiển thị
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.redAccent),
                                          onPressed: () {
                                            viewModel.removeFile(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'No files selected',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 900,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: LinearProgressIndicator(
                        value: viewModel.progressValue,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await viewModel.rotateFiles();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rotate_right,
                            color: Colors.black26), // Thay đổi icon theo ý muốn
                        SizedBox(width: 8), // Khoảng cách giữa icon và văn bản
                        Text(
                          'Xoay',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black26,
                      backgroundColor: Colors.white,
                      shadowColor: Colors.black26,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.black26),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();
}
