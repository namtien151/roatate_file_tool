import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:path/path.dart' as path;

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      HomeViewModel viewModel,
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
                  offset: Offset(0, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
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
                          SizedBox(height: 10),
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
                              await viewModel.pickFolder();
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
                  SizedBox(height: 10),
                  viewModel.selectedDirectory != null
                      ? Column(
                    children: [
                      Container(
                        width: 900,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Shadow color
                              offset: Offset(0, 4), // Shadow offset
                              blurRadius: 8, // Shadow blur radius
                              spreadRadius: 1, // Shadow spread radius
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(Icons.folder, color: Colors.amber),
                          title: Text(
                            '${viewModel.selectedDirectory!}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: Icon(viewModel.showFiles
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                            onPressed: () {
                              viewModel.toggleFilesVisibility();
                            },
                          ),
                        ),
                      ),

                      if (viewModel.showFiles)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            width: 900,
                            height: 370,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.black12,
                                width: 1,
                              ),

                            ),
                            child: viewModel.files != null &&
                                viewModel.files!.isNotEmpty
                                ? ListView.builder(
                              itemCount: viewModel.files!.length,
                              itemBuilder: (context, index) {
                                FileSystemEntity file =
                                viewModel.files![index];
                                FileStatusType status = viewModel
                                    .fileStatuses[index].status;
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(9),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 3),
                                        blurRadius: 10,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      path.basename(file.path),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // Hiển thị kích thước tệp nếu là tệp
                                        file is File
                                            ? Text(
                                          '${viewModel.formatFileSize(File(file.path).lengthSync())}', // Hiển thị kích thước tệp
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w300,
                                          ),
                                        )
                                            : Container(),
                                        // Hiển thị đường dẫn tệp
                                        Text(
                                          file.path, // Hiển thị đường dẫn đầy đủ
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        status == FileStatusType.idle
                                            ? Image.asset(
                                            'assets/image/close.png')
                                            : status ==
                                            FileStatusType
                                                .loading
                                            ? CircularProgressIndicator()
                                            : Icon(
                                          Icons
                                              .check_circle,
                                          color:
                                          Colors.green,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color:
                                              Colors.redAccent),
                                          onPressed: () {
                                            viewModel
                                                .removeFile(index);
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
                    ],
                  )
                      : Center(
                    child: Text(
                      'No folder selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 15),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  viewModel.outputDirectory.isEmpty
                      ? ElevatedButton(
                    onPressed: viewModel.pickOutputDirectory,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black26,
                      backgroundColor: Colors.white,
                      shadowColor: Colors.black26,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black26),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_download_outlined,
                            color: Colors
                                .black26), // Thay đổi icon theo ý muốn
                        SizedBox(
                            width: 8), // Khoảng cách giữa icon và văn bản
                        Text(
                          'Chọn nơi LƯU',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  )
                      :
                  ElevatedButton(
                    onPressed: () async {
                      await viewModel.runExecutable();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rotate_right, color: Colors.black26),
                        SizedBox(width: 8),
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
  HomeViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      HomeViewModel();
}

