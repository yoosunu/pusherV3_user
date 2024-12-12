import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:pusher_v3/pages/test.dart';
import 'pages/home.dart';
import 'package:pusher_v3/fetch.dart';
import 'package:pusher_v3/notification.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
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
  void onRepeatEvent(DateTime timestamp) async {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
      "IsRunning": isRunning,
      "IsLoading": isLoading,
    };
    FlutterForegroundTask.sendDataToMain(data);

    // background posting logic
    await postDataBG();
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

  void _sendDataToTask() {
    // Main(UI) -> TaskHandler
    //
    // The Map collection can only be sent in json format, such as Map<String, dynamic>.
    FlutterForegroundTask.sendDataToTask(Object);
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
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
      serviceId: 256,
      notificationTitle: 'Pusher_V3',
      notificationText: 'PusherV3 is running',
      notificationIcon: NotificationIcon(
        metaDataName: 'com.example.pusher_v3.service.PEAR_ICON',
        backgroundColor: Colors.deepPurple[300],
      ),
      // notificationButtons: [
      //   const NotificationButton(id: 'btn_hello', text: 'hello'),
      // ],
      notificationInitialRoute: '/',
      callback: startCallback,
    );
  }
}

Future<void> postDataBG() async {
  final List<String> urls = [
    'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=1&menu=2377',
    'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=2&menu=2377',
    'https://www.jbnu.ac.kr/web/news/notice/sub01.do?pageIndex=3&menu=2377',
  ];

  final Uri url = Uri.parse('https://backend.apot.pro/api/v1/notifications/');

  List<INotificationBG> scrappedDataBG = [];
  final results = await Future.wait(urls.map(fetchInfosBG));

  for (var result in results) {
    scrappedDataBG.addAll(result);
  }
  for (INotificationBG data in scrappedDataBG) {
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()), // 데이터를 JSON으로 인코딩
      );

      // 응답 상태 코드 확인
      if (response.statusCode == 201) {
        await FlutterLocalNotification.showNotification(data.code, data.title,
            '${data.code} ${data.tag} ${data.writer} ${data.etc}');
        print('succeed posting ${data.code}');
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Post erorr: $e');
    }
  }
}

void main() async {
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
