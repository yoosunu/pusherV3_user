// ignore_for_file: non_constant_identifier_names, avoid_print
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pusher_v3_user/fetch.dart';
import 'package:pusher_v3_user/notification.dart';
import 'package:pusher_v3_user/sqldbinit.dart';
import 'package:sqflite/sqflite.dart';
import 'pages/home.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() async {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  bool isRunning = false;
  bool isLoading = true;
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
    isRunning = true;
    isLoading = false;
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
      "IsRunning": isRunning,
      "IsLoading": isLoading,
    };
    FlutterForegroundTask.sendDataToMain(data);

    // background posting logic
    postDataBG();
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
    isRunning = false;
    isLoading = true;
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
    // print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}

Future<ServiceRequestResult> _startService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 512,
      notificationTitle: 'Pusher_V3_user',
      notificationText: 'PusherV3 is running',
      notificationIcon: NotificationIcon(
        metaDataName: 'com.example.pusher_v3_user.service.PEAR_ICON',
        backgroundColor: Colors.deepPurple[300],
      ),
      notificationButtons: [
        const NotificationButton(id: 'btn_stop', text: 'Stop'),
      ],
      notificationInitialRoute: '/',
      callback: startCallback,
    );
  }
}

Future<void> postDataBG() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  Database db = await dbHelper.database;
  List<Map<String, dynamic>> result =
      await db.rawQuery('SELECT MAX(code) as max_code FROM api');

  int codeMax = 0;
  if (result.isNotEmpty && result.first['max_code'] != null) {
    codeMax = result.first['max_code'] as int;
  }

  List<INotificationBG> scrappedDataBG = [];
  final Uri url = Uri.parse('https://backend.apot.pro/api/v1/notifications/');
  var results = await fetchInfosBG(url);
  scrappedDataBG.addAll(results);

  if (scrappedDataBG.isNotEmpty) {
    print(json.encode(scrappedDataBG[0].toJson()));
  }
  for (INotificationBG data in scrappedDataBG) {
    try {
      if (data.code > codeMax) {
        dbHelper.saveCode(data);
      }
    } catch (e) {
      // add a page that users can choose gonna get the error alarms or not
      await FlutterLocalNotification.showNotification(
          data.code, 'codeMax Error', '$e');
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotification.init();
  FlutterLocalNotification.requestNotificationPermissionAndroid();
  FlutterForegroundTask.initCommunicationPort();

  _startService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PushserV3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(
        title: 'Pusher',
      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomePage(title: 'Home'),
      },
    );
  }
}
