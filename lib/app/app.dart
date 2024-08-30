import 'package:roatate_file_tool/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:roatate_file_tool/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:roatate_file_tool/ui/views/home/home_view.dart';
import 'package:roatate_file_tool/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:roatate_file_tool/ui/dialogs/result_turn/result_turn_dialog.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    StackedDialog(classType: ResultTurnDialog),
// @stacked-dialog
  ],
)
class App {}
