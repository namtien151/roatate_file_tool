// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roatate_file_tool/ui/common/ui_helpers.dart';
import 'package:roatate_file_tool/ui/views/widget/text_model.dart';

void showNotify(
  BuildContext context, {
  double maxWidth = 500,
  required String titleText,
  String? contentText,
  bool success = false,
  bool error = false,
  bool warning = false,
}) {
  Color textColor = Colors.black;
  Color backgroundColor = Colors.white;
  IconData icon = Icons.abc;
  if (success) {
    textColor = const Color(0xFF43A047);
    backgroundColor = const Color(0xFFE8F5E9);
    icon = Icons.check_circle_outline_rounded;
  } else if (error) {
    textColor = const Color(0xFFF44336);
    backgroundColor = const Color(0xFFFFEBEE);

    icon = Icons.block;
  } else if (warning) {
    icon = Icons.warning_amber;
    textColor = const Color(0xFFE2A905);
    backgroundColor = const Color(0xFFFFF5D0);
  }
  OverlayEntry? overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (contextDialog) {
      return Positioned(
          top: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical:
                      screenWidthFraction(contextDialog, max: 16, dividedBy: 2),
                  horizontal: screenWidthFraction(contextDialog,
                      max: 16, dividedBy: 2)),
              width: screenWidthFraction(contextDialog, max: maxWidth),
              constraints: const BoxConstraints(
                maxWidth: 330,
              ),
              decoration: BoxDecoration(
                  border: Border.all(color: textColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: backgroundColor),
              child: boxNotify(
                context: context,
                titleText: titleText,
                contentText: contentText ?? "",
                icon: icon,
                textColor: textColor,
                onTap: () {
                  if (overlayEntry != null && overlayEntry!.mounted) {
                    overlayEntry?.remove();
                    overlayEntry = null;
                  }
                },
              ),
            ),
          ).animate().fade().moveX(end: 0, begin: 20));
    },
  );
  Overlay.of(context).insert(overlayEntry!);

  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  });
}

Widget boxNotify(
    {required String titleText,
    required BuildContext context,
    required String contentText,
    required Color textColor,
    Function()? onTap,
    required IconData icon}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            icon,
            size: 32,
            color: textColor,
          ),
          InkWell(
            onTap: onTap,
            child: Icon(
              Icons.close,
              size: 32,
              color: textColor,
            ),
          ),
        ],
      ),
      verticalSpaceSmall,
      ClassText.normal(
        text: titleText,
        maxLines: 2,
        colorText: textColor,
      ),
      verticalSpaceTiny,
      ClassText.normal(
        text: contentText,
        colorText: textColor,
        maxLines: 4,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
    ],
  );
}

showNotifySystemNotifications(bool success, BuildContext context,
    {String? title, String? subTitle}) {
  if (success) {
    showNotify(context,
        titleText: title ?? "Thành công",
        contentText: subTitle ?? "Thao tác của bạn trên hệ thống đã thành công",
        success: true);
  } else {
    showNotify(context,
        titleText: title ?? "Đã có lỗi xảy ra",
        contentText: subTitle ??
            "Thao tác của bạn trên hệ thống không thành công. Vui lòng đợi hoặc thực hiện lại thao tác!",
        error: true);
  }
}
