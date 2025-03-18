// The callback function should always be a top-level function.

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class BackgroundService {
  // static final BackgroundService _backgroundService =
  //     BackgroundService._backgroundService;
  //
  // factory BackgroundService() {
  //   return _backgroundService;
  // }
  @pragma('vm:entry-point')
  void startCallback() {
    // The setTaskHandler function must be called to handle the task in the background.
    FlutterForegroundTask.setTaskHandler(MyTaskHandler());
  }

  initMethod(context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestPermissionForAndroid().then((value) {
        initForegroundTask();
      });

      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        registerReceivePort(newReceivePort, context);
      }
    });
  }

 ReceivePort? receivePort;
  Future<void> requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }
    // if (!await FlutterForegroundTask.canDrawOverlays) {
    //   await FlutterForegroundTask.openSystemAlertWindowSettings();
    // }

    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      // await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        // id: 500,
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription: 'Video is uploading',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,

        // iconData: const NotificationIconDat
        // a(
        //   resType: ResourceType.mipmap,
        //   resPrefix: ResourcePrefix.ic,
        //   name: 'launcher',
        //   backgroundColor: Colors.orange,
        // ),
        // buttons: [
        //   const NotificationButton(
        //     id: 'sendButton',
        //     text: 'Send',
        //     // textColor: Colors.orange,
        //   ),
        //   const NotificationButton(
        //     id: 'testButton',
        //     text: 'Test',
        //     // textColor: Colors.grey,
        //   ),
        // ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),  foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ));
    //   const ForegroundTaskOptions(
    //     interval: 500,
    //     isOnceEvent: false,eventAction: ForegroundTaskEventAction(),
    //     autoRunOnBoot: true,
    //     allowWakeLock: true,
    //     allowWifiLock: true,
    //   ),
    // );
  }

 Future<bool> startForegroundTask(
     context, String title, String key, dynamic value) async {
  print('foreground Started');

  // Save data using the saveData function.
  await FlutterForegroundTask.saveData(key: key, value: value);

  // Register the receivePort before starting the service.
  final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
  final bool isRegistered = registerReceivePort(receivePort, context);
  if (!isRegistered) {
    print('Failed to register receivePort!');
    return false;
  }

  if (await FlutterForegroundTask.isRunningService) {
    print('service restarted');
    final result = await FlutterForegroundTask.restartService();
    return result is ServiceRequestSuccess;
  } else {
    print('service started');
    final result = await FlutterForegroundTask.startService(
      notificationTitle: title,
      notificationText: '',
      callback: startCallback,
    );
    return result is ServiceRequestSuccess;
  }
}


  Future<bool> isRunning() async {
    return FlutterForegroundTask.isRunningService;
  }

Future<bool> stopForegroundTask() async {
  print('closed service');

  // Call stopService and check the result type
  final result = await FlutterForegroundTask.stopService();

  // Check if the result is of type ServiceRequestSuccess
  return result is ServiceRequestSuccess;
}


  

  Future<bool> clear() {
    return FlutterForegroundTask.clearAllData();
  }

  bool registerReceivePort(ReceivePort? newReceivePort, context) {
    if (newReceivePort == null) {
      return false;
    }

    closeReceivePort();

    receivePort = newReceivePort;
    receivePort?.listen((data) {
      if (data is int) {
        print('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          // Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {
        print('timestamp: ${data.toString()}');
      }
    });

    return receivePort != null;
  }

  void closeReceivePort() {
    receivePort?.close();
    receivePort = null;
  }
}

class MyTaskHandler extends TaskHandler {
  TaskStarter? _sendPort;

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

// Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  // Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
  //   UploadProgressService uploadProgressService = UploadProgressService();
  //   // Start file upload here, not in the main isolate.
  //   // final uploading = startFileUpload();
  //   // ...
  //
  //   // Listen to uploading.snapshotEvents.
  //   // final snapshot = await uploading.snapshotEvents.first;
  //   // ...
  //
  //   double progressPercent = uploadProgressService.progress * 100;
  //   print('Upload progress: $progressPercent%');
  //   FlutterForegroundTask.updateService(
  //     notificationTitle: 'Upload in progress',
  //     notificationText: 'Upload progress: $progressPercent%',
  //   );
  //
  //   // Send data to the main isolate.
  //   sendPort?.send(uploadProgressService.progress);
  // }
  Future<void> onRepeatEvent(DateTime timestamp) async {
    UploadProgressService uploadProgressService = UploadProgressService();
    double progressPercent = uploadProgressService.progress * 100;
    print('Upload progress: $progressPercent%');
    FlutterForegroundTask.updateService(
      notificationTitle: 'Upload in progress',
      notificationText: 'Upload progress: $progressPercent%',
    );

    // Send data to the main isolate.
    // sendPort?.send(uploadProgressService.progress);
  }
  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  // UploadProgressService uploadProgressService = UploadProgressService();
  // @override
  // Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
  //   double progressPercent = uploadProgressService.progress * 100;
  //   print('Upload progress: $progressPercent%');
  //   FlutterForegroundTask.updateService(
  //     notificationTitle: 'Upload in progress',
  //     notificationText: 'Upload progress: $progressPercent%',
  //   );
  //
  //   // Send data to the main isolate.
  //   sendPort?.send(uploadProgressService.progress);
  // }

  // Called when the notification button on the Android platform is pressed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed >> $id');
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    // _sendPort?('onNotificationPressed');
  }

/*
  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) {
    // to do: implement onEvent
    throw UnimplementedError();
  }*/
}

class UploadProgressService {
  double progress = 0;
}
