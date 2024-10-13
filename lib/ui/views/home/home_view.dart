import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roatate_file_tool/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 700,
                  decoration: BoxDecoration(
                    color: Colors.white, // Màu nền của thanh
                    borderRadius: BorderRadius.circular(
                        2), // Góc bo tròn của thanh
                    border: Border.all(
                        color: Colors.black,
                        width: 1.0), // Viền của thanh
                  ),
                  child: Row(
                    children: [
                      // Nút chọn thư mục
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.black, // Màu của đường viền
                              width: 1.0,         // Độ dày của đường viền
                            ),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            await viewModel.pickFolder();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(halfScreenWidth(context) / 5, 40),
                            foregroundColor: Colors.black26,
                            backgroundColor: Colors.amber,
                            shadowColor: Colors.black26,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2), // Bo góc nếu cần
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, color: Colors.black26),
                              SizedBox(width: 8),
                              Text(
                                'Choose Folder',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                     SizedBox(
                       width: 10,
                     ),

                      // Văn bản hiển thị folder đã chọn
                      if (viewModel.selectedDirectory != null)
                        Container(
                          child: Expanded(
                            child: Text(
                              '${viewModel.selectedDirectory}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                              overflow: TextOverflow
                                  .ellipsis, // Giới hạn văn bản nếu quá dài
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        viewModel.outputDirectory,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: viewModel.pickOutputDirectory,
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(halfScreenWidth(context) / 5, 40),
                        foregroundColor: Colors.black26,
                        backgroundColor: Colors.amber,
                        shadowColor: Colors.black26,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2), // Bo góc nếu cần
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_download_outlined,
                              color:
                                  Colors.black26), // Thay đổi icon theo ý muốn
                          SizedBox(
                              width: 8), // Khoảng cách giữa icon và văn bản
                          Text(
                            'Chọn Nơi Lưu',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: screenWidth(context) / 1.6,
              height: 700,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    viewModel.selectedDirectory != null
                        ? Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.8,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.2), // Shadow color
                                      offset:
                                          const Offset(0, 4), // Shadow offset
                                      blurRadius: 8, // Shadow blur radius
                                      spreadRadius: 1, // Shadow spread radius
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.folder,
                                      color: Colors.amber),
                                  title: Text(
                                    viewModel.selectedDirectory!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              // if (viewModel.showFiles)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.8,
                                  height: 500,
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
                                            double progress = viewModel
                                                .fileStatuses[index].progress;

                                            return InkWell(
                                              onTap: () => viewModel
                                                  .openDialogResult(index),
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 10),
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
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Hiển thị kích thước tệp nếu là tệp
                                                      if (file is File)
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              viewModel.formatFileSize(
                                                                  File(file
                                                                          .path)
                                                                      .lengthSync()), // Hiển thị kích thước tệp
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                              ),
                                                            ),
                                                            if (viewModel
                                                                .isFileLarge(File(
                                                                        file.path)
                                                                    .lengthSync()))
                                                              const Text(
                                                                'Lưu ý: File này sẽ xu ly chậm',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            // Text('Processing File: ${viewModel.progress.toStringAsFixed(2)}%'),

                                                            // Hiển thị đường dẫn tệp
                                                            Text(
                                                              file.path, // Hiển thị đường dẫn đầy đủ
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      else
                                                        Container(),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      status ==
                                                              FileStatusType
                                                                  .idle
                                                          ? Image.asset(
                                                              'assets/image/close.png')
                                                          : status ==
                                                                  FileStatusType
                                                                      .loading
                                                              ? SizedBox(
                                                                  width: 50,
                                                                  child: Stack(
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            100.0, // Thay đổi kích thước theo nhu cầu
                                                                        height:
                                                                            100.0, // Thay đổi kích thước theo nhu cầu
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                3.0,
                                                                            color:
                                                                                Colors.green,
                                                                            // Điều chỉnh độ dày của vòng tròn
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: Text(
                                                                            '${(progress).toStringAsFixed(1)}%'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : const Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors
                                                                .redAccent),
                                                        onPressed: () {
                                                          viewModel.removeFile(
                                                              index);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Text(
                                            'No files selected',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'No folder selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                    const SizedBox(height: 15),
                    Container(
                      child: Text(
                        viewModel.processingStatus,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.8,
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
                          backgroundColor: Colors.white70,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 8,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await viewModel.runExecutable();
                                  for (int i = 0; i < viewModel.fileStatuses.length; i++) {
                                    viewModel.resetProgress(i);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black26,
                                  backgroundColor: Colors.white,
                                  shadowColor: Colors.black26,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Colors.black26),
                                  ),
                                ),
                                child: SizedBox(
                                  width: screenWidth(context) / 8,
                                  height: 50,
                                  child: Container(
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.rotate_right,
                                            color: Colors.black26),
                                        horizontalSpaceTiny,
                                        Text(
                                          'Xoay',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            if (viewModel.showDeleteButton)
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 8,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    viewModel.clearAll();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black26,
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.black26,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side:
                                      const BorderSide(color: Colors.black26),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 20),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete, color: Colors.black26),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Xóa Tất Cả',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel(context);
}
