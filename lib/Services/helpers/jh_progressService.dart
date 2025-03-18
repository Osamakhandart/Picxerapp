import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationService._internal();
  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            // onDidReceiveLocalNotification: onDidReceiveLocalNotification
            //new change here
            );
    // requestPermissions();
    //change done
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void requestPermissions() {
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    print(id);
    print(title);
    print(body);
    print(payload);
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title!),
    //     content: Text(body!),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           // Navigator.of(context, rootNavigator: true).pop();
    //           // await Navigator.push(
    //           //   context,
    //           //   MaterialPageRoute(
    //           //     builder: (context) => SecondScreen(payload),
    //           //   ),
    //           // );
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

  Future selectNotification(String payload) async {
    if (payload.isNotEmpty) {
      OpenFile.open(payload);
    }
  }

  sendNotification(title, body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('test', 'testing',
            channelDescription: 'your channel description',
            // icon: 'transparent',
            importance: Importance.max,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('transparent'));
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidNotificationDetails),
    );
  }

  Future<void> showProgressNotification(id, title, body, max, current) async {
    init();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // int id = 0;
    // id++;
    // final int progressId = id;

    // for (int i = 0; i <= maxProgress; i++) {
    if(Platform.isAndroid){
    await Future<void>.delayed(const Duration(seconds: 1), () async {
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('progress channel', 'progress channel',
              channelDescription: 'progress channel description',
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true,
              showProgress: true,
              maxProgress: max,
              // icon: 'transparent',
              largeIcon: DrawableResourceAndroidBitmap('transparent'),
              progress: current);
      final NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await flutterLocalNotificationsPlugin
          .show(id, title, body, notificationDetails, payload: 'item x');
    });}
    else{
      
      // iOS notification details
  final DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
    threadIdentifier: 'progress_notifications',
  );

  // Platform-specific notification details
  final NotificationDetails notificationDetails = NotificationDetails(
    
    iOS: iosNotificationDetails,
  );

  // Show the notification
  await flutterLocalNotificationsPlugin.show(
    id, // Unique notification ID
    title,
    '$body: $current / $max', // Progress text for iOS
    notificationDetails,
    payload: 'progress_update',
  );
}
    }
  

  Future<void> showInitialNotification(
      int id, String title, String body) async {
    init();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            // icon: 'transparent',
            largeIcon: DrawableResourceAndroidBitmap('transparent'),
            onlyAlertOnce: false);

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: 'item x');
  }

  Future<void> showCompletionNotification(
      int id, String title, String body) async {
    init();
    print(id);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('completion channel', 'completion channel',
            channelDescription: 'completion channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            // icon: 'transparent',
            largeIcon: DrawableResourceAndroidBitmap('transparent'),
            onlyAlertOnce: true);

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    String galleryUri =
        'content://media/internal/images/media'; // This is an example for Android
    await flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: galleryUri);
  }
  Future<void> clearAllNotifications() async {


  // Cancel all notifications
  await flutterLocalNotificationsPlugin.cancelAll();
}
}
// }
