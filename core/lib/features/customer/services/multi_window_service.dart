import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:hozmacore/constants/constants.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:window_manager/window_manager.dart';

abstract class IWindowService {
  Future<int> openNewWindow(String arguments);
  Future<List<int>> getOpenedWindowsId();
  sendMessageToWindows(int windowId, dynamic argument);
  Future<bool>closeWindow(int windowId);
}

class WindowService implements IWindowService {
  @override
  Future<int> openNewWindow(String? arguments) async {
    try {
      final window = await DesktopMultiWindow.createWindow(arguments);
      window
        ..setFrame(const Offset(0, 0) & const Size(1280, 720))
        ..center()
        ..show();
      return window.windowId;
        
    } catch (ex) {
      return Future.error(AppException(message: "Unable to open new Window"));
    }
  }

  @override
  sendMessageToWindows(int windowId, dynamic argument) async {
    try {
      await DesktopMultiWindow.invokeMethod(
          windowId, 'broadcast', argument);
    } catch (e) {
      return Future.error(
          AppException(message: "Unable to send message to window"));
    }
  }

  @override
  Future<List<int>> getOpenedWindowsId() async {
    try {
      var windowIds = await DesktopMultiWindow.getAllSubWindowIds();
      return windowIds;
    } catch (ex) {
      return Future.error(
          AppException(message: "Unable to get id of opened windows"));
    }
  }

  @override
  Future<bool> closeWindow(int windowId) async {
    try {
      var windowController = WindowController.fromWindowId(windowId);
      await sendMessageToWindows(windowId, MultiWindowMessage.CLOSE_WINDOW.name);
      await windowController.close();
      return true;
    } catch (ex) {
      return Future.error(
          AppException(message: "Unable to close opened windows"));
    }
  }
}
